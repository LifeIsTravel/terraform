#!/bin/bash

sudo apt-get update
sudo apt install postgresql-client-common postgresql-client
sudo apt install redis-tools 
sudo apt install unzip

${ssh_setting}

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

sudo -u ubuntu aws configure set aws_access_key_id "${aws_access_key_id}"
sudo -u ubuntu aws configure set aws_secret_access_key "${aws_secret_access_key}"
sudo -u ubuntu aws configure set region "${aws_region}"

source airflow_env/bin/activate
cd airflow

# Configure Airflow
export AIRFLOW_HOME=/home/ubuntu/airflow
sed -i "s/^load_examples = .*/load_examples = False/" /home/ubuntu/airflow/airflow.cfg
sed -i "s/^executor = .*/executor = CeleryExecutor/" /home/ubuntu/airflow/airflow.cfg
sed -i "s|^broker_url = .*|broker_url = redis://"${broker_url}"/0|" /home/ubuntu/airflow/airflow.cfg
sed -i "s|^result_backend = .*|result_backend = db+postgresql://username:password@"${meta_db_url}"/airflow|" /home/ubuntu/airflow/airflow.cfg
sed -i "s|^sql_alchemy_conn = .*|sql_alchemy_conn = postgresql+psycopg2://username:password@"${meta_db_url}"/airflow|" /home/ubuntu/airflow/airflow.cfg
mkdir -p $AIRFLOW_HOME/dags
mkdir -p $AIRFLOW_HOME/plugins
mkdir -p $AIRFLOW_HOME/config
mkdir -p $AIRFLOW_HOME/tests

# sudo -u ubuntu aws s3 cp s3://hellokorea-airflow-dags/ /home/ubuntu/airflow/
# pip install -r /home/ubuntu/airflow/dags/requirements.txt

cat << 'EOF' > /home/ubuntu/airflow_startup.sh
#!/bin/bash
source /home/ubuntu/airflow_env/bin/activate
airflow celery worker
EOF

chmod +x /home/ubuntu/airflow_startup.sh

sudo cat << 'EOF' > /etc/systemd/system/airflow_startup_service.service
[Unit]
Description=Worker Startup Script
After=network.target

[Service]
ExecStart=/home/ubuntu/airflow_startup.sh
User=ubuntu
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Initialize the database
airflow db init

sudo systemctl daemon-reload
sudo systemctl enable airflow_startup_service.service 

# Create admin user
# airflow users create -f Admin -l User -u devcourse -e purotae@gmail.com -r Admin -p HelloKorea0818