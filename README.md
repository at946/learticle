# Download
```
$ git clone https://github.com/at946/learticle
```

# Build
```
$ cd learticle
$ docker-compose build
```

# Create & migrate DB
```
$ docker-compose run web rails db:create
$ docker-compose run web rails db:migrate
```

# Start app
```
$ docker-compose up -d
```

# Stop app
```
$ docker-compose down
```