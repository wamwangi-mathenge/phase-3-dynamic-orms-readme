require 'sqlite3'
# Here, we are:=
  # Creating the database
  # Drop songs to avoid an error
  # Creating the songs table

# Creating the database
DB = {:conn => SQLite3::Database.new("db/songs.db")}

# Drop songs to avoid an error
DB[:conn].execute("DROP TABLE IF EXISTS songs")

# Creating a songs table
sql = <<-SQL
  CREATE TABLE IF NOT EXISTS songs (
  id INTEGER PRIMARY KEY,
  name TEXT,
  album TEXT
  )
SQL

DB[:conn].execute(sql)
DB[:conn].results_as_hash = true # When a SELECT statement is executed, don't return a database row as an array, return it as a hash with the column name and keys.
