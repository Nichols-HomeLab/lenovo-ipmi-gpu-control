# Use an NVIDIA CUDA base image
FROM nvidia/cuda:12.9.1-base-ubuntu22.04

# Set environment variables from build-time arguments
ENV HOST ${HOST}
ENV USER ${USER}
ENV PASSWORD ${PASSWORD}

# Update and install ipmitool
RUN apt-get update && apt-get install -y ipmitool

# Create the /config directory
RUN mkdir -p /config

# Copy the default ipmi.sh script into the image
COPY ipmi.sh /defaults/ipmi-default.sh

# Create a startup script
RUN echo '#!/bin/bash\n\
CONFIG_PATH="/config/ipmi.sh"\n\
if [ ! -f "$CONFIG_PATH" ]; then\n\
    echo "Creating default IPMI script at $CONFIG_PATH"\n\
    cp /defaults/ipmi-default.sh $CONFIG_PATH\n\
fi\n\
# Make the script executable\n\
chmod +x $CONFIG_PATH\n\
# Execute the user's script\n\
exec "$CONFIG_PATH"' > /usr/local/bin/startup.sh && chmod +x /usr/local/bin/startup.sh

# Set the startup script as the default command
CMD ["/usr/local/bin/startup.sh"]
