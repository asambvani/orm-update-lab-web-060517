require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade, :id
  # Remember, you can access your database connection anywhere in this class
  #  with DB[:conn]

  def initialize(name, grade, id=nil)
    @name = name
    @grade = grade
    @id = id
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade INTEGER
    );
    SQL

    DB[:conn].execute(sql)

  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE IF EXISTS students;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    if !@id
      sql = <<-SQL
      INSERT INTO students (
        name,
        grade
      )
      VALUES (
        ?,
        ?
      );
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    else self.update
    end

  end

  def self.find_by_name(name)
    sql = <<-SQL
    SELECT * FROM students
    WHERE name = ?
    LIMIT 1;
    SQL

    row = DB[:conn].execute(sql, name).flatten
    Student.new_from_db(row)
  end

  def update
    sql = <<-SQL
    UPDATE students
    SET name = ?,
    grade = ?
    WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.grade, self.id)

  end

  def self.create(name, grade)
    student = Student.new(name,grade)
    student.save
  end

  def self.new_from_db(row)
    student = Student.new(row[1],row[2])
    student.id = row[0]
    student
  end

end
