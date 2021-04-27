The project consists of three phases
1)	Application development, testing, and validation
2)	Docker container creation from the final application code.
3)	Deploy the application in Cloud using Terraform 
                   

VOICE ENABLED E-COMMERCE ONLINE SHOPPING CART

Project Phases:
1) Application development, testing, and validation.

   OS & pkgs required to build the project: # (OS used: ubuntu 20.04 & Python 3.8.5 Docker Image))
   
  
   a) install psycopg2 dependencies gcc postgresql libasound-dev portaudio19-dev libportaudio2 libportaudiocpp0 binaries.
   b) pip install --upgrade pip
   c) pip install Django pillow gunicorn SpeechRecognition PyAudio 

   d) Update the code and validate the code locally using below command
       python manage.py runserver 0.0.0.0:8000
   d) Configure gunicorn for outside connectivity:
    gunicorn RetailCom.wsgi:application --bind 0.0.0.0:8000
   
   Validate if the website and voice search feauture works fine.
    
   Upload the code to Github: 
     git init
     git clone github.com:x20182473/retailbazaar.git
     git add .
     git commit "application code changes"
     git push 
   <<Validate the changes updated>>

    Git hub link for this project hosted on private bucket.

   
2)	Docker container creation from the final application code.

     Build:
      # sudo docker build -t retail_django_final .
       Validate:
      # sudo docker run -p 8007:8000 --name siva2 retail_django_final gunicorn RetailCom.wsgi:application --bind 0.0.0.0:8000
       Add Tag:
      # sudo docker tag retail_dj_final tsivabe/retail_django:retail_dj_final
       Push to docker (Configure Host SSH keys to docker for passwordless connection)
      # sudo docker push tsivabe/retail_django:retail_dj_final



3)	Deploy the application in Cloud using Terraform 

     Install awscli on the ubuntu machine
     configure aws keys on to it under ~/.aws/credentials file.
      cd to the directory created for terraform
     run below commands:

      # terraform init
      # terraform plan
      # terraform apply

     capture the load balancer url from the terraform out put and view it in web browser for the connectivity check.
 Login to AWS console and check the EC2 instance, Load balancer, Autoscaling group, security group, Database resources has been created on it.
      we have created the S3 , S3 glacier manually, sns, sms cloud watch an cloud trail services manually.

Project code uploaded on GITHUB Link : https://github.com/x20182473/retailbazaar
Docker image loaded on Docker hub link :  https://hub.docker.com/repository/docker/tsivabe/retail_django

