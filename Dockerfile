# https://github.com/doctor-server/steamcmd
FROM doctorserver/steamcmd:latest AS builder

# Set environment variables
ENV APP_ID=730

# Create the update script
RUN cat <<EOF > ${HOME}/script.txt
@ShutdownOnFailedCommand 1
@NoPromptForPassword 1
force_install_dir ${HOME}/serverfiles
login anonymous
app_update ${APP_ID} validate
quit
EOF

# Run the SteamCMD script
RUN steamcmd +runscript ${HOME}/script.txt

# Set the remote build ID as an argument and validate it using the script
ARG REMOTE_BUILDID
COPY validate_buildid.sh ${HOME}/validate_buildid.sh
RUN chmod +x ${HOME}/validate_buildid.sh && ${HOME}/validate_buildid.sh ${APP_ID} ${REMOTE_BUILDID}

# Remove all map files if the 'slim' tag is specified
ARG TAG
RUN if [ "${TAG}" = "slim" ]; then rm -rf ${HOME}/serverfiles/game/csgo/maps/*; fi


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
