FROM images.sbgenomics.com/aleksandar_danicic/plink-1-90:0

# Install scripts
RUN mkdir /home/analyst
COPY *.sh /home/analyst/
RUN chmod a+x /home/analyst/*.sh
