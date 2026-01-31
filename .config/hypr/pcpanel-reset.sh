  #!/bin/bash
  # /usr/local/bin/reset-pcpanel.sh

  VENDOR="0483"
  PRODUCT="a3c5"

  for dev in /sys/bus/usb/devices/*; do
    if [ -f "$dev/idVendor" ] && [ -f "$dev/idProduct" ]; then
      if [ "$(cat $dev/idVendor)" = "$VENDOR" ] && [ "$(cat $dev/idProduct)" = "$PRODUCT" ]; then
        DEVICE=$(basename "$dev")
        echo "Resetting PCPanel Pro at $DEVICE..."
        echo "$DEVICE" | tee /sys/bus/usb/drivers/usb/unbind > /dev/null
        sleep 1
        echo "$DEVICE" | tee /sys/bus/usb/drivers/usb/bind > /dev/null
        echo "Done"
        exit 0
      fi
    fi
  done

  echo "PCPanel Pro not found"
  exit 1
