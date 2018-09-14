# Neighbourly

### Instantly deploy your own version with Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

After deployment you will need to run `heroku pg:psql < pcode_table.sql` to get the postcode search feature to work.

### Background notes

- This repository contains all the code and instructions you need to instantly run your own version of the Neighbourly doorknocking tool
- The deploy button above will create an app with its own database for supporter details, including the areas of the map they claim. By default the address and walklist data will be served by pre-existing backend infrastructure.
- Optionally, if you would like to run your own version of the Neighbourly backend infrastructure you can follow the instructions available in [this google doc](https://docs.google.com/document/d/1Amn246ERnAL_LTfBhCIZpRyTPwwtUYUeD2u90qPPl0c/edit).
    - Those instructions outline all steps required to create the full Neighbourly backend using Amazon Web Services (AWS).
    - The google doc explains how to deploy the code and other files in this repository, which includes all necessary deployment scripts and Lambda functions: https://github.com/TheCommonsLibrary/neighbourly-serverless.

### Run the app locally (optional)

1. Download the code in this repository (click the "Clone or download" button above, then select "Download ZIP"). Once your download completes, unzip the folder.

2. Open the “Terminal” application on your Mac (or the equivalent application for your Operating System) and navigate to your new Neighbourly folder on the command line by following this instruction:
    - Type `cd`, press the spacebar, then drag and drop the Neighbourly folder onto the command line (like [this example](https://s3-ap-southeast-2.amazonaws.com/neighbourly-data/change-directory-command-line.gif)). It should result in output something like this: `cd /Users/JoeBloggs/Desktop/Neighbourly`

3. Install all project dependencies with the following commands:
    ```
    gem install bundler -v 1.15.3
    bundle install
    ```

4. Create the database by running the following commands:
    ```
    psql
    CREATE DATABASE neighbourly ENCODING 'UTF_8';
    CREATE DATABASE neighbourly_test ENCODING 'UTF_8';
    \q
    ```

5. Run the database migrations with the following commands:
    ```
    DATABASE_URL="postgres://localhost/neighbourly" rake db:migrate
    psql neighbourly < pcode_table.sql
    ```

6. Create a new `.env` file in the project root and set the environment variables according to the examples in `.env.example`

7. Finally start the application by running the following command:
    ```
    ruby app.rb
    ```

### Updating the design to suit your organisation

1. Inside the `public/images` folder, replace the `home-background.jpg` with a photo of your choice. This is the image used on the main login screen.

2. Inside the `public/images` folder, replace the `home-logo.png` with the logo you would like to appear in the top-left of the main login screen.
    - Ideally you should use the inverse version of your logo (e.g. white, with a transparent background), given this logo appears on top of a photo.
    - A square version of your logo will work well. For reference, the current example logo has a 5:4 aspect ratio.

3. Inside the `public/images` folder, replace the `map-logo.png` with your primary logo to appear in the top-left of the main map screen.
    - A square version of your logo will work well. For reference, the current example logo has a 5:4 aspect ratio.

4. Update the `favicon.ico` image inside the `public` folder.
