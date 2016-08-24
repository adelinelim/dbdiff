# DBDiff
  DBDiff is a tool that allows you to compare data in the database after some CRUD actions.

  It is useful to **compare** the state of the data **before and after** an action has been taken.

DBDiff supports these database adapters:
- **mysql**
- **postgres**

# Setup
  Clone dbdiff to your machine and run bundle install in Terminal.
  ```
  bundle install
  ```

# Usage
  1. Go to the cloned folder in Terminal.
  ```
  cd dbdiff
  ```

  2. Run the dbdiff in Terminal.
  ```
  ruby dbdiff.rb
  ```

  3. When the Sinatra service is running, open the browser with the link:
  ```
  http://localhost:4567/setup
  ```

  4. Click **Add Connection** button to add database connection.

  Fill in the database connection detail and click **Add** button.
  The database connection will be added into config/databases.json

  5. Once the database connection is added, you can then go back to the [setup page](http://localhost:4567/setup) and select the "Database Name" that you want the data comparison and click **Compare** button to proceed.

  6. You can now view the data differences after some CRUD actions to the database.

  7. You can press refresh (**command + R**) or click **Compare** button again to compare the data continuously.

# How it works
1. Everytime the "**Compare**" button is clicked in the /compare page, it will write all the data from database into <.filenumber>.json file.

  The file number counter is auto generated and stored in .filenumber file.

2.  DBdiff will always compares the last two <.filenumber>.json files (located in data/*.json folder) to generate the data differences result into data/diff.json.

  Example:
  ```
  The background processes:
  1. Write new changes into: 2.json
  2. Compare the saved files: compare previous data (1.json) with new generated data (2.json)
  3. Generate differences in diff.json
  4. Display differences in page
  ```

  **Note:** You can delete unwanted json data files in /data/<.filenumber>.json file
