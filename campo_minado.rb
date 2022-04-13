# Breno de Almeida Sa

class Minesweeper  
	def initialize(width, height, num_mines)  
		# Instance variables  
		@width = width  
		@height = height		
		@num_mines = num_mines
		@original_board = create_board
		@board = Marshal.load(Marshal.dump(@original_board))
		fill_board
		@victory = true		
	end 
	
	############################ public methods ###################################
	
	def play(x, y) 
		puts "Jogada"	
		puts "x: #{x}"
		puts "y: #{y}"
	
		if(@board[y][x] != "clear_cell" && @board[y][x] != "flag")
			if(@board[y][x] == "bomb")
				@board[y][x] = "B"
				@victory = false 
			else				
				set_neighbors(x, y)
			end
			return true
		else
			puts "Invalid"	
			return false
		end		 
	end 

	def flag(x, y) 
		puts "Flag"	
		puts "x: #{x}"
		puts "y: #{y}"
		
		if(@board[y][x] != "clear_cell")
			if(@board[y][x] == "flag")
				@board[y][x] = original_board[y][x]
			else
				@board[y][x] = "flag"
			end
			return true
		else
			puts "Invalid"	
			return false
		end			
	end 

	def still_playing?	
		return (@victory == false || !covered_board?) ? false : true		
	end 

	def victory?
		return @victory 
	end   

	def board_state(hash = {})	
		return (hash[:xray] == true && !still_playing?) ? @board : hidden_bombs_board			
	end 	

	############################### private methods	##############################
	
	def covered_board? 
		for i in 0..(@board.length - 1)	
			if (@board[i].include? 'unknown_cell')
				return true
			end
		end
		return false
	end
	
	def set_neighbors(x, y)
		num_bombs = 0
		for i in -1..1		
			for j in -1..1
				if (valid_neighbor(x+j, y+i))
					if (@board[y+i][x+j] == "bomb")
						num_bombs += 1
					end
					if (@board[y+i][x+j] == "unknown_cell")
						@board[y+i][x+j] = "clear_cell"
						if(num_bombs == 0)
							set_neighbors(x+j, y+i)
						end
					end
				end
			end
		end
		@board[y][x] = "#{num_bombs}"
		@board[y][x].sub! '0', 'clear_cell'		
	end
	
	def valid_neighbor(x, y)
		return ((y >= 0 && y < @height) && (x >= 0 && x < @width))
	end
	
	def hidden_bombs_board		
		new_board = Marshal.load(Marshal.dump(@board))
		for i in 0..(new_board.length - 1)		
			for j in 0..(new_board[i].length - 1)
				new_board[i][j].sub! 'bomb', 'unknown_cell'
			end			
		end
		return new_board
	end
	
	def create_board
		return Array.new(@height) { Array.new(@width, 'unknown_cell') }
	end

	def fill_board
		for i in 1..@num_mines			
			begin
				x = rand(@width)
				y = rand(@height)
			end while @board[y][x] == "bomb"		
				@board[y][x] = "bomb"
		end
	end
end

class SimplePrinter  
	$stdout.sync = true
	alias default_print print
	
	def print(input)	
		for i in 0..(input.length - 1)		
			for j in 0..(input[i].length - 1)
				default_print  " #{input[i][j]}"
			end
			default_print  "\r\n"
		end
	end
end

class PrettyPrinter 
	$stdout.sync = true  
	alias default_print print
	
	def initialize 
		@board_format = {
		  "unknown_cell" => '.',
		  "clear_cell" =>  ' ',
		  "bomb" =>  '#',
		  "flag" =>  'F'
		}
	end
	
	def print(input)	
		for i in 0..(input.length - 1)		
			for j in 0..(input[i].length - 1)
				output = " #{input[i][j]}"					
				matcher = /#{@board_format.keys.join('|')}/
				default_print output.gsub(matcher, @board_format)
			end
			default_print  "\r\n"
		end
	end
end


########################TESTE#########################


width, height, num_mines = 20, 20, 80
game = Minesweeper.new(width, height, num_mines)

while game.still_playing?
  valid_move = game.play(rand(width), rand(height))
  valid_flag = game.flag(rand(width), rand(height))
  if valid_move or valid_flag
	printer = (rand > 0.5) ? SimplePrinter.new : PrettyPrinter.new
	printer.print(game.board_state)		
  end  
end

puts "Fim do jogo!"
if game.victory?
  puts "Você venceu!"
else
  puts "Você perdeu! As minas eram:"
  PrettyPrinter.new.print(game.board_state(xray: true))
end