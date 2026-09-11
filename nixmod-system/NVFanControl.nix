{ pkgs, ... }:


{

systemd.timers.NVFanControl = {
  wantedBy = [ "timers.target" ];
   timerConfig = {
      OnBootSec = "1s";
      OnUnitActiveSec = "1s";
    };
};

systemd.services.NVFanControl = {
    enable = true;
    description = "NVIDIA Fan Control Bash Script";
    serviceConfig = { Type = "oneshot";  };
    path = [pkgs.gawk]; #used for sine wave curve calc
    wantedBy = [ "default.target" ];
    partOf = ["default.target" ];
    script = ''
    declare -i gpuTemp
    declare -i gpuTempFloor
    declare -i gpuTempCeiling
    declare -i targetFanSpeed
    declare -i fallbackFanSpeed

    rawTemp=$(/run/current-system/sw/bin/nvidia-settings -q gpucoretemp -c 0 2> /dev/null | grep -Po "(?<=: )[0-9]+(?=\.)")

    if [[ -z "$rawTemp" ]]; then
      # Query failed (e.g. no X session for nvidia-settings to talk to) - fail safe at 100%
      finalFanSpeed=100
      echo "Failed to read GPU temp | Target Fan Speed: $finalFanSpeed (safety fallback)"
    else
      gpuTemp=$rawTemp
      gpuTempFloor=$((gpuTemp<50 ? 50 : gpuTemp)) #minimum bound of fan curve
      gpuTempCeiling=$((gpuTempFloor>80 ? 80 : gpuTempFloor)) #maximum bound of fan curve
      targetFanSpeed=$(gawk -v temp=$gpuTempCeiling 'BEGIN{printf "%.0f", 35 * sin((temp-1.5)/10)+65}') #calculate the target fan speed based on a sine curve from x=50 to x=80. round to the nearest whole number.
      finalFanSpeed=$((targetFanSpeed>=30 && targetFanSpeed<=100 ? targetFanSpeed : 100)) #if a valid fan target wasn't calculated, turn fans on 100% as a safety measure
      echo "Current Temp: $gpuTemp | Target Fan Speed: $finalFanSpeed"
    fi

    /run/current-system/sw/bin/nvidia-settings -a GPUTargetFanSpeed="$finalFanSpeed" -c 0
    '';
  };
}
