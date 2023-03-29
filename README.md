# Installation manual



## Foreword

This project is the Docker Compose part of the QuizGame application. This is the right project you are supposed to install to start the entirety of the application all at once. We strongly discourage you to follow the installation manuals on the other projects, but here are the links for them if you want to check them out -- their README might be of interest to you:

- https://github.com/realraec/quizgame-backend
- https://github.com/realraec/quizgame-frontend



## Prerequisites

The first five steps might be skippable -- depending on whether you have already installed the necessary tools for other projects -- but the last two are needed: the app needs a user, a database, for that user to have enough rights on this database, and a running PostgreSQL DBMS to work properly.

* Install Docker for Windows:
  https://docs.docker.com/desktop/install/windows-install/
  
* All the commands thereafter will have to be typed in Windows Terminal, in the WSL environment you must have set up in order to have Docker for Windows. (The actual tutorial for WSL2 alone is to be found here, but please follow the previous link instead : https://learn.microsoft.com/en-us/windows/wsl/install )

* Start Docker Compose:

  ```
  start docker-desktop
  ```

With this done, you should be able to follow the next steps to get a functional backend application running.



## The app itself

* Clone this repository:

  ```
  git clone https://github.com/realraec/quizgame-docker-compose.git .
  ```

* Navigate your way to the root of the application:

  ```
  cd ./quizgame-docker-compose
  ```

* Start everything at once based on the `docker-compose.yml` file:

  ```
  docker-compose up
  ```
  
* Wait until you get the following line -- this is not a command:

  ```
  ** Angular Live Development Server is listening on 0.0.0.0:4200, open your browser on http://localhost:4200/ **
  ```

Congratulations, the app is now running, and with it, the database is listening on port 5432, the backend on port 8080, and the frontend on port 4200. Feel free to access the application here : http://localhost:4200/ .
Use any of the following accounts (using their username and password -- note that the passwords are encrypted in the database) to access whatever part of the application they should get to see :

- admin1 - P@ssW0rd1
  admin2 - P@ssW0rd2
  admin3 - P@ssW0rd3
- intern4 - P@ssW0rd1
  intern5 - P@ssW0rd2
  intern6 - P@ssW0rd3
  intern7 - P@ssW0rd4
  intern8 - P@ssW0rd5
  intern9 - P@ssW0rd6
  intern10 - P@ssW0rd7
  intern11 - P@ssW0rd8
  intern12 - P@ssW0rd9



## Known bugs and workarounds

* If you wish to reset the process and start from scratch (usually after freeing ports or killing a concurrent DBMS service), try :

  ```
  docker-compose down --volumes
  docker-compose up --build --force-recreate
  ```

* If for some reason you do not have the latest version of the frontend part of the app (based on a distant repository), try:

  ```
  docker compose build --no-cache
  ```

* If you cannot configure the database from your CLI, open pgAdmin4 or any other management tool for PostgreSQL, query your main database (right click > query tool), and try:

* If you encounter a problem and all else fails, please feel free to reach out to any of the contributors of the project -- the one in charge of the Dockerizing being Pierre CHIMOT, he might be able to help you better.

