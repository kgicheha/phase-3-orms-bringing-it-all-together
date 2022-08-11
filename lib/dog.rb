class Dog

    attr_accessor :id, :name, :breed
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    #creates tables
    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
            SQL
        DB[:conn].execute(sql)
    end

    #deletes table
    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES(?,?)
        SQL

        #inster the dog
        DB[:conn].execute(sql, self.name, self.breed)

        #get the dog ID from database and save it to the Ruby instance
        self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]

        #return the Ruby instance
        self
    end

    #creates a new dog object and uses the save method to save the dog to the database
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
    end

    #creates an instance with correspoding attribute values
    #converts what the database gives us into a Ruby object
    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    #returns an arrary of dog instances for all records in the dogs table
    def self.all
        sql = <<-SQL
        SELECT *
        FROM dogs
        SQL
        ##sends each row of data in the dogs database to the new_from_db which will convert them to Ruby objects
        DB[:conn].execute(sql).map do |row|
            self.new_from_db(row)
        end
    end

    #returns an instance of dog that matches the name from the DB
    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE name = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end

    #return a new dog object by id
    def self.find(id)
        sql = <<-SQL
            SELECT *
            FROM dogs
            WHERE id = ?
            LIMIT 1
        SQL

        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end
end
