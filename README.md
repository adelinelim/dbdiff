# DBDiff
DBDiff is a tool that allows you to compare data in the database after some CRUD actions.

DBDiff supports these database adapters:
- mysql
- postgres

# Setup
Clone dbdiff to your machine and run bundle install in Terminal
```
bundle install
```

# Usage
  1) Go to the cloned folder in Terminal
```
cd dbdiff
```

  2) Run the dbdiff in Terminal
```
ruby dbdiff.rb
```

  3) When the Sinatra service is running, open the browser with the link:
```
http://localhost:4567/setup
```

  4) Click **Add Connection** button to add database connection.

  Fill in the database connection detail and click **Add** button.
  The database connection will be added into config/databases.json

  5) Once the database connection is added, you can then go back to the [setup page](http://localhost:4567/setup) and select the "Database Name" that you want the data comparison and click **Compare** button to proceed.

  6) You can now view the data differences after some CRUD actions to the database.

  7) You can refresh or click compare again to compare the continuous data

# How it works:
1. Everytime when you clicked the "**Compare**" button, it will write all the data from database into <.filenumber>.json file.

  The file number counter is stored in .filenumber, it is an auto generated number.

2.  DBdiff will always compares the last two <.filenumber>.json files (located in data/*.json folder) to generate the data differences result into data/diff.json.

  Example
  ```
  write data into: <filenumber>.json
  compare: compare 1.json with 2.json
  then generate: diff.json
  ```
