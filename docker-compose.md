# Etude de cas : déployer un projet avec DOCKER COMPOSE

## Le choix de DOCKER COMPOSE

Pour répondre à la question "pourquoi DOCKER COMPOSE ?", il faut d'abord répondre à la question "pourquoi DOCKER ?". Dans l'ordre, cela nous donne donc :

- Pourquoi DOCKER ? Lorsque l'on mentionne DOCKER, on dit généralement que c'est pour éviter le problème du "ça ne marche pas sur ta machine, mais ça marche sur la mienne". Lors d'un travail en groupe pour l'école, de nombreux problèmes ont pu survenir au moment de l'import et lancement des différentes parties du projet sur un autre poste : version JAVA incompatible entre la machine et le projet, NODE pas installé correctement, port déjà en cours d'utilisation par un autre DBMS... Pour simpliciter l'expérience de développement (et d'utilisation, à terme), la décision a donc été prise de containériser le projet : plus besoin de se soucier de tous ces problèmes, à partir du moment où une machine a DOCKER d'installé, elle devrait pouvoir lancer le projet dans son intégralité sans problème.

- Pourquoi DOCKER COMPOSE ? Tout simplement, pour avoir tous les bénéfices de DOCKER mais orchestrer tous les conteneurs, les faire communiquer entre eux, et gagner du temps au lancement d'un projet pour déployer tous ses services en une seule commande. Si au cours du travail en groupe, il y a pu y avoir l'étape intermédiaire de n'utiliser "que" des conteneurs DOCKER individuels (en se basant directement sur les Dockerfile nécessaires avec l'outil `docker`), l'objectif est toujours resté de pouvoir déployer l'ensemble de la stack d'un coup (via l'outil `docker compose`) : la base de donnée se lance, le backend se lance, la base de donnée s'alimente, le frontend se lance... et tout cela, en seulement une commande, grâce à DOCKER COMPOSE.

Le travail en groupe mentionné ci-dessus est accessible sur un dépôt GITHUB à l'adresse suivante : https://github.com/realraec/quizgame-docker-compose . A ce lien se trouve la partie "containérisation" de l'application, mais il est possible d'accéder aux autres dépôts via les liens présents dans le fichier `README.md` à la racine. Il est également utile de mentionner que ce dépôt a été configuré de façon à respecter les normes communautaires recommandées pour les projets open source, comme la présence de fichiers tels que `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `LICENSE`, ou `SECURITY.md` -- pour voir la checklist, se rendre sur le dépôt, cliquer sur l'onglet "Insights", puis sur le sous-onglet "Community Standards".

---
---

## Mettre en place l'orchestration

### Tout ce qui n'est pas des "services"

Une bonne pratique en containérisation est de tout tagger et versioner, pour éviter qu'un projet ne fonctionne plus avec le temps et les différentes mises à jour des différents applicatifs (s'il se base sur la dernière version de ces derniers). Il est donc recommandé de renseigner la `version` du fichier DOCKER COMPOSE dans l'entête de ce dernier, avant le mot clef `service` et des différents services qui sont amenés à être déployés ensemble -- à noter que dans les fichiers YAML, l'indentation fait partie de la syntaxe, les espaces en début de ligne dans les exemples qui vont suivre sont donc volontaires :

```yaml
version: '3'
services:
  ...
```

---

### La base de données

Le projet tel qu'il a été pensé doit être composé d'une base de données qui permet de stocker toutes les informations nécessaires au bon fonctionnement de l'application et de pouvoir l'utiliser en gardant sa progression. Il a été décidé d'utiliser le DBMS appelé POSTGRESQL, mais nous ne rentrerons pas dans les détails de justification quant à pourquoi cette technologie. Cette "partie" de projet correspond donc à un service à déployer, et donc à un conteneur qui doit se baser sur une image précise, voici donc dans un premier temps le `Dockerfile`, puis l'extrait qui l'utilise dans le `docker-compose.yml` :

```Dockerfile
FROM postgres:15.2
LABEL maintainer="realraec.xyz"
COPY init-user-db.sh /docker-entrypoint-initdb.d/init-user-db.sh
```

Ligne par ligne, ce Dockerfile se traduit par :
- On base notre image sur une image déjà existante sur le DOCKER HUB appelée `postgres`, avec le tag `15.2` ;
- On renseigne la personne ou l'entitée en charge de la mise à jour de notre image comme étant `realraec.xyz` ;
- On copie le fichier `init-user-db.sh` présent sur le dépôt au sein du dossier `docker-entrypoint-initdb.d` à la racine de la nouvelle image.

```yaml
  quizgame-database:
    build: ./database
    env_file:
      - ./.env
    ports:
      - 5432:5432
    user: postgres
    healthcheck:
      test: pg_isready
      start_period: 5s
      interval: 2s
      retries: 15
```

Ligne par ligne, cet extrait de code du `docker-compose.yml` se traduit par ce qui suit :
- On définit un service que l'on appelle `quizgame-database` ;
- On indique que ce service doit être basé sur une image locale, et on renseigne le path relatif qui mène à son Dockerfile -- dans le dossier `database` du répertoire courant ;
- On indique que des variables d'environnment à utiliser pour ce service se trouvent à l'intérieur d'un fichier ;
- On renseigne le path relatif qui mène à ce fichier contenant les variables d'environnement -- le fichier `.env` du répertoire courant ;
- On indique que des ports entre hôte et conteneur doivent pouvoir communiquer ;
- On renseigne les ports, avec en premier le port hôte (5432), et en second le port conteneur (5432) ;
- On indique l'utilisateur auquel se connecter pour effectuer des commandes d'administration de la base de données, ici `postgres` ;
- On indique que l'état de santé de ce service doit être testé (car un autre service en dépendra pour se lancer) ;
- On renseigne la nature de ce healthcheck, ici une commande qui ne doit pas se terminer en échec -- `pg_isready` retourne un message d'erreur si le service n'est pas prêt à accepter des connexions ;
- On renseigne le délai avant la première tentative (5 secondes) ;
- On renseigne l'intervalle entre deux tentatives (2 secondes) ;
- On renseigne le nombre maximum de tentatives avant que le service soit considéré comme "unhealthy" (15).

---

### Le serveur backend

Le projet tel qu'il a été pensé doit être composé d'un serveur pour le backend pour pouvoir effectuer et traîter des requêtes, de telle sorte à ce que l'applicatif ne soit pas inerte. Il a été décidé d'utiliser le language JAVA, le JDK 17, et le gestionnaire MAVEN, mais nous ne rentrerons pas dans les détails de justification quant à pourquoi cette technologie. Cette "partie" de projet correspond donc à un service à déployer, et donc à un conteneur qui doit se baser sur une image précise, voici donc dans un premier temps le `Dockerfile`, puis l'extrait qui l'utilise dans le `docker-compose.yml` :


```Dockerfile
FROM bitnami/git:2.40.1 as git
WORKDIR /usr/app
RUN git clone https://github.com/realraec/quizgame-backend.git .

FROM maven:3.9.1-amazoncorretto-17
LABEL maintainer="realraec.xyz"
WORKDIR /usr/app
COPY --from=git /usr/app /usr/app
RUN mvn package
# RUN mvn install -DskipTests
ENTRYPOINT java -jar ./target/quizgame-0.0.1-SNAPSHOT.jar
```

Ligne par ligne, ce Dockerfile se traduit par :
- On crée une première image :
  - On base notre image sur une image déjà existante sur le DOCKER HUB appelée `bitnami/git`, avec le tag `2.40.1` et on lui donne pour alias "git" -- c'est pour ne pas avoir à installer l'outil `git` que l'on se base sur cette image;
  - On se positionne dans le dossier `/usr/app` ;
  - On clone un dépôt GITHUB dans le dossier où l'on se trouve ;
- On crée une seconde (et dernière) image :
  - On base notre image sur une image déjà existante sur le DOCKER HUB appelée `maven`, avec le tag `3.9.1-amazoncorretto-17` -- c'est pour ne pas avoir à installer l'outil `mvn` et l'outil `java` que l'on se base sur cette image;
  - On renseigne la personne ou l'entitée en charge de la mise à jour de l'image comme étant `realraec.xyz` ;
  - On se positionne dans le dossier `/usr/app` ;
  - On copie l'intégralité du dossier `/usr/app` présent sur l'image à l'alias "git" au sein du dossier du même nom de la nouvelle image ;
  - On package l'application JAVA et toutes ses dépendances (avec ou sans jouer les tests unitaires) de telle sorte à ce qu'un fichier `quizgame-0.0.1-SNAPSHOT.jar` soit généré dans le sous-dossier `target` du répertoire courant ;
  - On renseigne la commande qui doit être jouée au lancement de l'image, ici lancer le projet via l'exécutable généré précédemment.

```yaml
  quizgame-backend:
    build: ./backend
    env_file:
      - ./.env
    ports:
      - 8080:8080
    depends_on:
      quizgame-database:
        condition: service_healthy
    healthcheck:
      test: curl --fail --request GET http://localhost:8080/actuator/health
      start_period: 10s
      interval: 2s
      retries: 15
```

Ligne par ligne, cet extrait de code du `docker-compose.yml` se traduit par ce qui suit :
- On définit un service que l'on appelle `quizgame-backend` ;
- On indique que ce service doit être basé sur une image locale, et on renseigne le path relatif qui mène à son Dockerfile -- dans le dossier `backend` du répertoire courant ;
- On indique que des variables d'environnment à utiliser pour ce service se trouvent à l'intérieur d'un fichier ;
- On renseigne le path relatif qui mène à ce fichier contenant les variables d'environnement -- le fichier `.env` du répertoire courant ;
- On indique que des ports entre hôte et conteneur doivent pouvoir communiquer ;
- On renseigne les ports, avec en premier le port hôte (8080), et en second le port conteneur (8080) ;
- On indique que ce service ne doit être lancé qu'après un (ou plusieurs) autre(s) sevice(s) ;
- On donne le nom du service duquel ce service dépend, ici `quizgame-database` ;
- On donne la condition que l'autre service doit respecter pour que ce service puisse se lancer, ici que son healthcheck passe (`service_healthy`) ;
- On indique que l'état de santé de ce service doit être testé (car un autre service en dépendra pour se lancer) ;
- On renseigne la nature de ce healthcheck, ici un appel à un des API exposés par le service s'il est bien lancé ;
- On renseigne le délai avant la première tentative (10 secondes) ;
- On renseigne l'intervalle entre deux tentatives (2 secondes) ;
- On renseigne le nombre maximum de tentatives avant que le service soit considéré comme "unhealthy" (15).

---

### L'initialisation par appels API

Le projet tel qu'il a été pensé doit avoir une base de donnée alimentée au lancement du projet, de telle sorte à ce que certaines données soient déjà présentes dans la base de données avant toute intervention de l'utilisateur. Il a été décidé d'utiliser un jeu automatisé de collection POSTMAN (utilisant l'outil NEWMAN) de façon à envoyer des requêtes aux APIs pour vérifier que toutes les vérifications aient bien été effectuées lors de chacune des requêtes, et que les données ne soient pas corrompues, mais nous ne rentrerons pas dans les détails de justification quant à pourquoi cette technologie. Cette "partie" de projet correspond donc à un service à déployer, et donc à un conteneur qui doit se baser sur une image précise, voici donc dans un premier temps le `Dockerfile`, puis l'extrait qui l'utilise dans le `docker-compose.yml` :

```Dockerfile
FROM postman/newman:5.3.1
LABEL maintainer="realraec.xyz"
WORKDIR /usr/app
COPY initialization.json .
```

Ligne par ligne, ce Dockerfile se traduit par :
- On base notre image sur une image déjà existante sur le DOCKER HUB appelée `postman/newman`, avec le tag `5.3.1` -- c'est pour ne pas avoir à installer l'outil `newman` que l'on se base sur cette image;
- On renseigne la personne ou l'entitée en charge de sa mise à jour comme étant `realraec.xyz` ;
- On se positionne dans le dossier `/usr/app` ;
- On copie le fichier `initialization.json` présent sur le dépôt dans le répertoire courant sur la nouvelle image.

```yaml
  quizgame-initialization:
    build: ./initialization
    command:
      run /usr/app/initialization.json
      --env-var "URL=http://quizgame-backend:8080"
      -r cli,json
      --reporter-json-export="reports/initialization-report.json"
    depends_on:
      quizgame-backend:
        condition: service_healthy
    healthcheck:
      test: bash -c "[ -f /reports/initialization-report.json ]"
      start_period: 5s
      interval: 2s
      retries: 15
    profiles:
      - init
```

Ligne par ligne, cet extrait de code du `docker-compose.yml` se traduit par ce qui suit :
- On définit un service que l'on appelle `quizgame-initialization` ;
- On indique que ce service doit être basé sur une image locale, et on renseigne le path relatif qui mène à son Dockerfile -- dans le dossier `initialization` du répertoire courant ;
- On indique qu'une commande soit être exécutée au lancement du conteneur :
  - On joue la collection présente à l'endroit renseigné, avec le nom renseigné ;
  - On surcharge une variable de collection de façon à pouvoir communiquer avec le service de base de données ;
  - On demande deux types de sortie : un en tant que logs dans l'invité de commandes, et un en tant que fichier JSON ;
  - On renseigne le path relatif où le rapport au format JSON doit être généré ;
- On indique que ce service ne doit être lancé qu'après un (ou plusieurs) autre(s) sevice(s) ;
- On donne le nom du service duquel ce service dépend, ici `quizgame-backend` ;
- On donne la condition que l'autre service doit respecter pour que ce service puisse se lancer, ici que son healthcheck passe (`service_healthy`) ;
- On indique que l'état de santé de ce service doit être testé (pour vérifier que l'initialisation a bien été effectuée) ;
- On renseigne la nature de ce healthcheck, ici une vérification que le rapport de collection a bien été généré à l'endroit indiqué ;
- On renseigne le délai avant la première tentative (5 secondes) ;
- On renseigne l'intervalle entre deux tentatives (2 secondes) ;
- On renseigne le nombre maximum de tentatives avant que le service soit considéré comme "unhealthy" (15) ;
- On indique que ce service ne doit être lancé que si un certain profil est renseigné au moment du déploiement de la stack ;
- On renseigne le nom de ce profil (`init`).


---

### Le client frontend

Le projet tel qu'il a été pensé doit être composé d'un client pour le frontend, de façon à ce que l'utilisateur ne soit pas obligé d'exécuter des requêtes par un outil tel que POSTMAN, et qu'il puisse avoir accès à une interface graphique. Il a été décidé d'utiliser le framework ANGULAR, mais nous ne rentrerons pas dans les détails de justification quant à pourquoi cette technologie. Cette "partie" de projet correspond donc à un service à déployer, et donc à un conteneur qui doit se baser sur une image précise, voici donc dans un premier temps le `Dockerfile`, puis l'extrait qui l'utilise dans le `docker-compose.yml` :

```Dockerfile
FROM node:16.19.1
LABEL maintainer="realraec.xyz"
WORKDIR /usr/app
RUN git clone https://github.com/realraec/quizgame-frontend.git .
RUN npm install
ENTRYPOINT npm start
```

Ligne par ligne, ce Dockerfile se traduit par :
- On base notre image sur une image déjà existante sur le DOCKER HUB appelée `node`, avec le tag `16.19.1` -- c'est pour ne pas avoir à installer l'outil `git` et l'outil `npm` que l'on se base sur cette image;
- On renseigne la personne ou l'entitée en charge de sa mise à jour comme étant `realraec.xyz` ;
- On se positionne dans le dossier `/usr/app` ;
- On clone un dépôt GITHUB dans le répertoire courant ;
- On installe le projet ANGULAR et toutes ses dépendances, de telle sorte à ce qu'un fichier `package.json` soit généré dans le répertoire courant ;
- On renseigne la commande qui doit être exécutée au lancement de l'image, ici lancer le projet via le script principal qui utilise le fichier généré précedemment.

```yaml
  quizgame-frontend:
    build: ./frontend
    ports:
      - 4200:4200
```

Ligne par ligne, cet extrait de code du `docker-compose.yml` se traduit par ce qui suit :
- On définit un service que l'on appelle `quizgame-frontend` ;
- On indique que ce service doit être basé sur une image locale, et on renseigne le path relatif qui mène à son Dockerfile -- dans le dossier `frontend` du répertoire courant ;
- On indique que des ports entre hôte et conteneur doivent pouvoir communiquer ;
- On renseigne les ports, avec en premier le port hôte (4200), et en second le port conteneur (4200).

---

### Validateur syntaxique et révélateur de configuration

Bien qu'il n'y ait pas vraiment d'outil spécifique à DOCKER COMPOSE autre que les vérificateurs de syntaxe de YAML, si on tente de lancer un projet via la commande `docker compose up`, un message d'erreur est renvoyé avec le numéro de ligne et la raison de l'échec au déploiement de la stack. Il existe toutefois un outil qui permet non seulement de valider la syntaxe d'un fichier DOCKER COMPOSE, mais aussi d'en révéler le contenu exact : `docker compose config`. Cette commande permet (lorsque la syntaxe est correcte) d'afficher exactement la configuration utilisée par le moteur DOCKER COMPOSE lors du déploiement de la stack, avec toutes les données, y compris celles cachées ou omises dans le fichier original -- à noter que les ressources sont désormais classées par ordre alphabétique, tout comme les clefs, et que la sous commande `config` fonctionne comme la sous-commande `up`, à savoir qu'il faut appliquer le(s) profile(s) désiré(s) pour inclure le(s) service(s) concerné(s). Voyons quel type d'informations a été rajouté (ou interprété différemment) à notre stack :

- Le fichier en lui-même s'appelle bien `docker-compose.yaml`, pourtant un autre nom est attribué à la stack qu'il va orchestrer, et c'est celui du dossier dans lequel il se trouve :

  ```yaml
  name: quizgame-docker-compose
  ```

- Les différents composants de notre projet sont censés communiquer, et donc être sur un même réseau. N'étant pas renseigné dans le fichier original, ce réseau (par défaut) apparaît bien dans la configuration, et tous les services mentionnent bien qu'ils l'utilisent :

  ```yaml
  networks:
    default:
      name: quizgame-docker-compose_default
  
  services:

    quizgame-database:
      networks:
        default: null
  ```

- L'instruction `env-file` est transformée en `environment`. Le contenu du fichier `.env` est affiché plutôt qu'un path vers ce dernier, mettant en clair toutes les variables d'environnement qui y ont définies :

  ```yaml
    quizgame-backend:
      environment:
        DB_NAME: quizgame
        DB_PASSWORD: password123
        DB_SERVICE: quizgame-database
        DB_USERNAME: dev
        LOG_LEVEL: INFO
        POSTGRES_DB: db
        POSTGRES_PASSWORD: 321password
        POSTGRES_USERNAME: postgres
  ```

- L'instruction `ports` est explicitée avec son mode et son protocole en plus du port source et du port cible. Ici le port 4200 du conteneur est mappé avec le port 4200 de la machine hôte pour pour laisser passer des données dans les deux sens via le protocole TCP :

  ```yaml
    quizgame-frontend:
      ports:
      - mode: ingress
        target: 4200
        published: "4200"
        protocol: tcp
  ```

- L'instruction `build` comprend désormais le path absolu (plutôt que relatif) vers le Dockerfile, ainsi que le nom de ce dernier :

  ```yaml
    quizgame-initialization:
      build:
        context: /home/realraec/IdeaProjects/quizgame-docker-compose/initialization
        dockerfile: Dockerfile
  ```
