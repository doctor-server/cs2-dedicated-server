# https://github.com/doctor-server/steamcmd
FROM doctorserver/steamcmd:latest AS builder

# Set environment variables
ENV APP_ID=730

# Run the SteamCMD script
COPY script.txt ${HOME}/script.txt
RUN steamcmd +runscript ${HOME}/script.txt


# https://github.com/doctor-server/steamcmd
FROM doctorserver/steamcmd:latest

# Copy only the necessary files from the builder stage to the final image
COPY --from=builder --chown=${USER}:${USER} ${HOME}/serverfiles ${HOME}/serverfiles

# Create a symbolic link to the CS2 server files for easier volume mounting
RUN ln -s ${HOME}/serverfiles/game/csgo /csgo

# Switch to the steam user for security reasons
USER ${USER}

# Set the working directory to the server files directory
WORKDIR ${HOME}/serverfiles/game/bin/linuxsteamrt64
