require "pg"
require "pry"

class DatabasePersistence
  def initialize(logger)
    # @session = session
    # @session[:lists] ||= []
    @db = PG.connect(dbname: "todos")
    @logger = logger
  end

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    @db.exec_params(statement, params)
  end
  
  def find_list(id)
    # @session[:lists].find { |l| l[:id] == id }
    sql = "SELECT * FROM lists WHERE id = $1"
    result = query(sql, id)
    
    tuple = result.first
    list_id = tuple["id"].to_i
    todos = find_todos_for_list(list_id)
    {id: list_id, name: tuple["name"], todos: todos}
    
    # query = <<~SQL
    #   SELECT lists.id AS list_id, 
    #         lists.name AS list_name,
    #         todos.id AS todo_id,
    #         todos.name AS todo_name,
    #         todos.completed AS todo_status
    #     FROM lists INNER JOIN todos ON lists.id = todos.list_id
    #     WHERE lists.id = $1
    #     SQL
    # result = @db.exec_params(query, [id])
    
    # todo_array = result.map do |tuple|
    #   {id: tuple["todo_id"].to_i, 
    #   name: tuple["todo_name"], 
    #   completed: tuple["todo_status"] == "t"}
    # end
    
    # {id: result.field_values("list_id").first, 
    # name: result.field_values("list_name").first, 
    # todos: todo_array}
  end

  def all_lists
    # @session[:lists]
    sql = "SELECT * FROM lists;"
    result = query(sql)
    
    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos_for_list(list_id)
      {id: tuple["id"], name: tuple["name"], todos: todos}
    end
  end

  def create_new_list(list_name)
    # id = next_element_id(@session[:lists])
    # @session[:lists] << { id: id, name: list_name, todos: [] }
  end

  def delete_list(id)
    # @session[:lists].reject! { |list| list[:id] == id }
  end

  def update_list_name(id, new_name)
    # list = find_list(id)
    # list[:name] = new_name
  end

  def create_new_todo(list_id, todo_name)
    # list = find_list(list_id)
    # id = next_element_id(list[:todos])
    # list[:todos] << { id: id, name: todo_name, completed: false }
  end

  def delete_todo_from_list(list_id, todo_id)
    # list = find_list(list_id)
    # list[:todos].reject! { |todo| todo[:id] == todo_id }
  end

  def update_todo_status(list_id, todo_id, new_status)
    # list = find_list(list_id)
    # todo = list[:todos].find { |t| t[:id] == todo_id }
    # todo[:completed] = new_status
  end

  def mark_all_todos_as_completed(list_id)
    # list = find_list(list_id)
    # list[:todos].each do |todo|
    #   todo[:completed] = true
    # end
  end
  
  private
  
  def find_todos_for_list(list_id)
    todo_sql = "SELECT * FROM todos WHERE list_id = $1"
    todos_result = query(todo_sql, list_id)
      
    todos_result.map do |todo_tuple|
      { id: todo_tuple["id"].to_i, 
        name: todo_tuple["name"], 
        completed: todo_tuple["completed"] == "t" }
    end
  end
end