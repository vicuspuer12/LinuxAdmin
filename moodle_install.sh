!#/bin/bash
# Step 1 LAMP server installaton
#Update the system and install git, Apache, PHP and modules required by Moodle
sudo apt-get update
sudo apt-get install -y apache2 php7.4 libapache2-mod-php7.4 php7.4-mysql graphviz aspell git 
sudo apt-get install -y clamav php7.4-pspell php7.4-curl php7.4-gd php7.4-intl php7.4-mysql ghostscript
sudo apt-get install -y php7.4-xml php7.4-xmlrpc php7.4-ldap php7.4-zip php7.4-soap php7.4-mbstring
#Install Debian default database MariaDB 
sudo apt-get install -y mariadb-server mariadb-client
echo "Step 1 has completed."

# Step 2 Clone the Moodle repository into /opt and copy to /var/www
# Use MOODLE_401_STABLE branch as Debian 11 ships with php7.4
echo "Cloning Moodle repository into /opt and copying to /var/www/"
echo "Be patient, this can take several minutes."
cd /var/www
sudo git clone https://github.com/moodle/moodle.git
cd moodle
sudo git checkout -t origin/MOODLE_401_STABLE
echo "Step 2 has completed."

# Step 3 Directories, ownership, permissions, php.ini changes and virtual hosts 
sudo mkdir -p /var/www/moodledata
sudo chown -R www-data /var/www/moodledata
sudo chmod -R 777 /var/www/moodledata
sudo chmod -R 755 /var/www/moodle
# Change the Apache DocumentRoot using sed so Moodle opens at http://webaddress
sudo cp /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/moodle.conf
sudo sed -i 's|/var/www/html|/var/www/moodle|g' /etc/apache2/sites-available/moodle.conf
sudo a2dissite 000-default.conf
sudo a2ensite moodle.conf
sudo systemctl reload apache2
# Update the php.ini files, required to pass Moodle install check
sudo sed -i 's/.*max_input_vars =.*/max_input_vars = 5000/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/.*post_max_size =.*/post_max_size = 80M/' /etc/php/7.4/apache2/php.ini
sudo sed -i 's/.*upload_max_filesize =.*/upload_max_filesize = 80M/' /etc/php/7.4/apache2/php.ini
# Restart Apache to allow changes to take place
sudo service apache2 restart
echo "Step 3 has completed."


# Step 4 Set up cron job to run every minute 
echo "Cron job added for the www-data user."
CRON_JOB="* * * * * /var/www/moodle/admin/cli/cron.php >/dev/null"
echo "$CRON_JOB" > /tmp/moodle_cron
sudo crontab -u www-data /tmp/moodle_cron
sudo rm /tmp/moodle_cron
echo "Step 4 has completed."

# Step 5 Secure the MySQL service and create the database and user for Moodle
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 6)
MYSQL_MOODLEUSER_PASSWORD=$(openssl rand -base64 6)
# Set the root password using mysqladmin
sudo mysqladmin -u root password "$MYSQL_ROOT_PASSWORD"
# Create the Moodle database and user
echo "Creating the Moodle database and user..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" <<EOF
CREATE DATABASE moodle DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'moodleuser'@'localhost' IDENTIFIED BY '$MYSQL_MOODLEUSER_PASSWORD';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, CREATE TEMPORARY TABLES, DROP, INDEX, ALTER ON moodle.* TO 'moodleuser'@'localhost';
FLUSH PRIVILEGES;
\q
EOF
# Display the generated passwords (if needed, for reference)
echo "SQL root password: $MYSQL_ROOT_PASSWORD, moodle SQL password: $MYSQL_MOODLEUSER_PASSWORD"
sudo chmod -R 777 /var/www/moodle
echo "Step 5 has completed."
