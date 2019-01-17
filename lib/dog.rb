class Dog

  attr_accessor :name, :breed, :id
  @@all = []

  def initialize (name:, breed:, id:nil)
    @name = name
    @breed =  breed

    @@all << self
  end

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

  def self.drop_table
    sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL
    DB[:conn].execute(sql)
    @@all.clear
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    end
    self
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.create(hash)
    dog = Dog.new(hash)
    dog.save
    dog
  end

  def self.find_by_id(id)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE id = ?
      LIMIT 1
    SQL
    array = DB[:conn].execute(sql, id).flatten
    Dog.new_from_db(array)
  end

  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ?
      LIMIT 1
    SQL
    array = DB[:conn].execute(sql, name).flatten
    Dog.new_from_db(array)
  end

  def self.new_from_db(array)
    hash = {name:array[1],breed:array[2]}
    dog = Dog.new(hash)
    dog.id= array[0]
    dog
  end

  def self.find_or_create_by(name:,breed:)
    sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? AND breed = ?
      LIMIT 1
    SQL
    dog = DB[:conn].execute(sql, name, breed).flatten

    if !dog.empty?
      dog_instance = Dog.new_from_db(dog)
    else
      hash = {name:name,breed:dog}
      dog_instance = Dog.create(hash)
    end
    dog_instance
  end

end
