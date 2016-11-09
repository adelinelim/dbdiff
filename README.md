# DBDiff
DBDiff is a tool that allows developers to **compare** changes to the database's data after some actions executed.
It allows you to view the **differences** between **before** and **after** CRUDs actions.

# Supports:
DBDiff supports these database adapters:
- **mysql**
- **postgres**

# Usage
  1. Run the below command in terminal to start dbdiff,
  which internally it run **bundle install** and **ruby dbdiff.rb**
  ```
  ./run
  ```

  2. When the Sinatra server started, open the browser
  ```
  http://localhost:4567/setup
  ```

  3. Click **Add Connection** button to add a database connection.

  Fill in the database connection detail and click **Add** button.
  The database configuration details will be added to config/databases.json

  4. Once the database connection is added, you can then go back to the [setup page](http://localhost:4567/setup) and select the "Database Name" that you want to compare and click **Compare** button to start the data comparison.

  5. Data comparison results will be displayed after some CRUD actions to the database.

  6. Press refresh (**command + R**) or click **Compare** button again to compare the data continuously.

  **Note:** For the first time, in order to compare differences between before and after some actions, you will need to click Compare button again to generate another data JSON file to start the data comparison.

# How it works
1. Every time the "**Compare**" button is clicked in the /compare page, it will write all the data from the database into <.filenumber>.json file.

  The file number counter is auto generated and stored in the .filenumber file.

2.  DBdiff will always compares the last two <.filenumber>.json files (located at data/*.json folder) to generate the data differences result into data/diff.json.

  Example:
  ```
  The background processes:
  1. Write new changes to 2.json
  2. Compare the saved files: compare previous data (1.json) with newly generated data (2.json)
  3. Generate differences in diff.json
  4. Display differences to the page
  ```

  **Note:** You can delete unwanted json data files in /data/<.filenumber>.json file
