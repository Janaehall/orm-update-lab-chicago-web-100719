require_relative "../config/environment.rb"

class Student
  attr_accessor :name, :grade
  attr_reader :id

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
      )
      SQL
      DB[:conn].execute(sql)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE students;")
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL
      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end

  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?, grade = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end

  def self.create(name, grade)
    student = self.new(name, grade)
    student.save
    student
  end

  def self.new_from_db(row)
    self.new(row[1], row[2], row[0])
  end

  def self.all
    array = DB[:conn].execute("SELECT * FROM students")
    array.map do |student|
      self.new_from_db(student)
    end
  end

  def self.find_by_name(name)
    student_info = DB[:conn].execute("SELECT * FROM students WHERE name = ? LIMIT 1", name)[0]
    self.new_from_db(student_info)
  end
  



end
