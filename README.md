# DBDiff
DBDiff is a tool that allows you to compare data in the database after some CRUD actions.

DBDiff supports these database adapters:
- mysql
- postgres

# Setup
clone dbdiff to your machine
1. run bundle install

# Usage
1. Go to the cloned folder in Terminal
```
cd dbdiff
```
2. Run the server_work
```
ruby server_work.rb
```
3. When the Sinatra service is running, open the browser with the link:
```
http://localhost:4567/setup
```
4. Click **Add Connection** button to add database connection
The database connection will be added into config/databases.json
```

```
5. Once the database connection is added, you can then go back to the setup page http://localhost:4567/setup and select the Database Name that you wanted to a data comparison and click **Compare** button
6.
#### Note: DBdiff will always compare the last two json files to generate the data differences result
