# Installation manual

## Foreword

This project is the Docker Compose part of the QuizGame application. This is the right project you are supposed to install to start the entirety of the application all at once. We strongly discourage you to follow the installation manuals on the other projects, but here are the links for them if you want to check them out -- their README might be of interest to you:

- https://github.com/realraec/quizgame-backend
- https://github.com/realraec/quizgame-frontend

---

## Prerequisites

The first five steps might be skippable -- depending on whether you have already installed the necessary tools for other projects -- but the last two are needed: the app needs a user, a database, for that user to have enough rights on this database, and a running PostgreSQL DBMS to work properly.

* Install Docker for Windows:
  https://docs.docker.com/desktop/install/windows-install/
  
* All the commands thereafter will have to be typed in Windows Terminal, in the WSL environment you must have set up in order to have Docker for Windows. (The actual tutorial for WSL2 alone is to be found here, but please follow the previous link instead : https://learn.microsoft.com/en-us/windows/wsl/install )

* 0.1 | Start Docker Desktop by double clicking the icon, or do:

  ```
  start docker-desktop
  ```

With this done, you should be able to follow the next steps to get a functional application running.

---

## Starting the app for the first time

* 1.1 | Clone this repository:

  ```
  git clone https://github.com/realraec/quizgame-docker-compose.git .
  ```

* 1.2 | Navigate your way to the root of the application:

  ```
  cd ./quizgame-docker-compose
  ```

* 1.3 | If you wish to use other credentials as the ones provided by default, or configure the variable environments differently, open the `.env.sample` file at the root of the project, override any environment variable you want (without simple or double quotes), and save the file as `.env` -- it is very important that you give the file this name, or else it will not be taken into account at all.

* 1.4 | Build the images before creating containers:

  ```
  docker compose build --no-cache
  ```

* 1.5 | Start everything at once based on the `docker-compose.yml` file:

  ```
  docker compose --profile=init up
  ```
  
* 1.6 | Wait until you get the following line -- this is not a command:

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

---

## Exiting, restarting, keeping changes or not

* 2.1 | To stop the containers currently running, press Ctrl+C, and to restart them without losing any of your progress (since the database is now populated with your own data, too), do:

  ```
  docker compose down
  docker compose up
  ```

* 2.2 | If you want to delete everything in your database and start over with a cleanly-populated database, do -- but notice the use of the `-` character in `docker-compose`:

  ```
  docker-compose down --volumes
  docker-compose --profile=init up --build --force-recreate
  ```

---

## Known bugs and workarounds

* 3.1 | If you are facing an issue the solution to which seems to be freeing ports, killing a concurrent DBMS service, or restarting a Docker network, you might have to perform a hard reset; see 2.2.

* 3.2 | If you do not have the latest version of either the frontend or backend part of the app (which are based on distant repositories unlike the other services) OR if you wish to change the log level for the backend part fo the application (see 1.3), you will have to rebuild the images; see 1.4.

* 3.3 | If you cannot configure the database from your CLI, open pgAdmin4 or any other management tool for PostgreSQL, query your main database (right click > query tool), and try:

  ```sql
  CREATE USER ${DB_USERNAME:dev};
  ALTER USER ${DB_USERNAME:dev} WITH ENCRYPTED PASSWORD '${DB_PASSWORD:password123}';
  CREATE DATABASE ${DB_NAME:quizgame} WITH OWNER ${DB_USERNAME:dev};
  ```

* If you encounter a problem and all else fails, please feel free to reach out to any of the contributors of the project -- the owner being [realraec](mailto:realraec@gmail.com).
