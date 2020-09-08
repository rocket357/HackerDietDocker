FROM httpd:latest

WORKDIR /usr/local/apache2/build

RUN apt-get update && \
apt-get -y install libapache2-mod-perl2 libgd-gd2-perl libssl-dev cpanminus wget \\
certbot python-certbot-apache make build-essential weblint texlive-latex-base

RUN wget -O nuweb.tar.gz https://sourceforge.net/project/nuweb/files/latest/download && \
mkdir -p /usr/local/apache2/build/nuweb && \
cpanm -i CGI Digest::SHA1 XML::LibXML Crypt::OpenSSL::AES Crypt::CBC && \
tar zxf nuweb.tar.gz -C /usr/local/apache2/build/nuweb && \
cd /usr/local/apache2/build/nuweb/nuweb-* && \
make nuweb && \
cp nuweb /usr/bin

RUN wget https://www.fourmilab.ch/hackdiet/online/download/1.0/hdiet-1.0.tar.gz && \
tar zxf hdiet-1.0.tar.gz -C /usr/local/apache2/build && \
sed -i -e 's@PRODUCTION/Web@/usr/local/apache2/htdocs@' Makefile && \
sed -i -e 's@PRODUCTION/Cgi@/usr/local/apache2/cgi-bin@' Makefile && \
sed -i -e 's@PRODUCTION/Exe@/usr/local/apache2/bin@' Makefile && \
cd /usr/local/apache2/build/ && PERL5LIB=/usr/local/apache2/build make dist && \
cp /usr/local/apache2/htdocs/webapp.html /usr/local/apache2/htdocs/index.html


# Uncomment and ensure your container can be reached on port 80 publicly
# to generate your own Lets Encrypt certs during container build...
#certbot --apache

WORKDIR /usr/local/apache2
EXPOSE 80

CMD ["httpd-foreground"]
