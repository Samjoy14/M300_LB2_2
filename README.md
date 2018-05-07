# M300_LB2_2

Vagrantfile
-------------
Zuerst habe ich eine Docker Umgebung aufgebaut. Ein Beispiel File und der Code befindet sich <a href="https://github.com/mc-b/devops/tree/master/docker/dc">Hier</a>.
Deshalb musste ich eine Docker Standard Vagrantfile erstellt Aus diesem Grund habe ich ein Beispiel Vagrantfile genommen und dementsprechend modifiziert.

Für alle VMs wird die Ubuntu Box verwendet und hier noch den <a href="https://app.vagrantup.com/ubuntu/boxes/xenial64">Link</a>. 
Bei meinen Fall habe in einem Container zwei VMs erstellt. Hier noch die dazu gehörige Vagrantfile. 

Hier sind die wichtigste Links:
<a href="https://docs.docker.com/samples/library/mysql/#start-a-mysql-server-instance">MySQL;</a>
<a href="https://docs.docker.com/samples/library/owncloud/#-via-docker-stack-deploy-or-docker-compose">OWNCLOUD;</a>
<a href="https://hub.docker.com/r/zercle/docker-webmin/">WEBMIN_DOCKER</a>

MySQL inkl. OWNCLOUD
----------
Vagrantfile:
```
Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/xenial64"

  # Create a public network, which generally matched to bridged network.
  #config.vm.network "public_network"
  config.vm.network "private_network", ip:"192.168.100.101" 
  config.vm.network "forwarded_port", guest:8080, host:8080, auto_correct: true
  
  # Share an additional folder to the guest VM.
  # config.vm.synced_folder "../data", "/vagrant_data"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = "2048"
  end
  
  # Docker Provisioner
  config.vm.provision "docker" do |d|
   d.pull_images "mysql"
   d.pull_images "owncloud"
   d.run "mysql", image: "mysql", args: "-e MYSQL_ROOT_PASSWORD=secret -e MYSQL_USER=test -e MYSQL_PASSWORD=secret -e MYSQL_DATABASE=test --restart=always"
   d.run "owncloud", image: "owncloud", args: "--link owncloud_mysql:mysql -p 10000:80 --restart=always"
  end
end
```
Webmin
---------
Was ist Webmin? Webmin lauscht im Hintergrund auf Anfragen aus dem Internet oder dem lokalen Netz. Mit einem Webbrowser können die verschiedenen Server-Prozesse oder Daemonen administriert werden, die auf einem Unix-Rechner laufen. Hierzu benötigt der administrierende Benutzer keinerlei Admin-Rechte, sondern lediglich Rechte für das Paket, das er administrieren soll. Diese Rechte werden vom Webmin-Administrator kontrolliert. So ist es beispielsweise möglich, einem Webmin-User nur die Administration von DNS zu erlauben, wofür er auf der Shell-Ebene Root-Rechte benötigen würde. (Hierfür gibt es allerdings auch ein spezielles Modul namens Usermin, das speziell auf die Bedürfnisse von Benutzern ausgerichtet ist, und eigenständig auf Port 10000 (Vorgabe) läuft – und systemkritische Komponenten schon von Haus aus außen vor lässt.) Ein weiteres Modul namens Virtualmin erlaubt die einfache Konfiguration verschiedener Serverdienste wie beispielsweise Mailserver und MySQL.

### Dockerfile
```
FROM ubuntu:16.04
MAINTAINER Samjoy Sivagurunathan <samjoy.sivagurubathan@hotmail.ch>

# Installation & Konfiguration
RUN apt-get -qq update
RUN sed -i '$adeb https://github.com/chsliu/docker-webmin.git' /etc/apt/sources.list
RUN cd /root
RUN apt-get -y -qq install apt-transport-https
RUN apt-get -qq update
RUN apt-get -y install apt-utils
RUN rm /etc/apt/apt.conf.d/docker-gzip-indexes
RUN apt-get purge apt-show-versions
RUN apt-get -o Acquire::GzipIndexes=false update
RUN apt-get -y install apt-show-versions
RUN apt-get -y install webmin

HEALTHCHECK --interval=5m --timeout=3s CMD curl -f https://localhost:10000 || exit 1

EXPOSE 10000

CMD /usr/bin/touch /var/webmin/miniserv.log && /usr/sbin/service webmin restart && /usr/bin/tail -f /var/webmin/miniserv.log
```

### Container starten
```
docker build -t webmin 
docker run -d -p 10000:443  --name webmin webmin
```
Der IP Adresse heisst "192.168.100.101:10000",weil es oben definiert worden war.
Nun kann man Webmin über die Benutzer Oberfläche zugreifen. Und zwar über unter [https://192.168.100.101:10000](https://192.168.100.101:10000) erreicht werden.

Alle Informationen, Angaben und Textbeiträge innerhalb sind ohne Gewähr auf Vollständigkeit und Richtigkeit.
