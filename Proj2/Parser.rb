# https://www.cs.rochester.edu/~brown/173/readings/05_grammars.txt
#
#  "TINY" Grammar
#
# PGM        -->   STMT+
# STMT       -->   ASSIGN   |   "print"  EXP
# ASSIGN     -->   ID  "="  EXP
# EXP        -->   TERM   ETAIL
# ETAIL      -->   "+" TERM   ETAIL  | "-" TERM   ETAIL | EPSILON
# TERM       -->   FACTOR  TTAIL
# TTAIL      -->   "*" FACTOR TTAIL  | "/" FACTOR TTAIL | EPSILON
# FACTOR     -->   "(" EXP ")" | INT | ID
# ID         -->   ALPHA+
# ALPHA      -->   a  |  b  | … | z  or
#                  A  |  B  | … | Z
# INT        -->   DIGIT+
# DIGIT      -->   0  |  1  | …  |  9
# WHITESPACE -->   Ruby Whitespace

#
#  Parser Class
#
load "Token.rb"
load "Lexer.rb"
$errorCount = 0
class Parser < Scanner
	# Initialize the parser
	def initialize(filename)
    	super(filename)
    	consume()
   	end
   	
	# Iterate to the next Token
	def consume()
      	@lookahead = nextToken()
      	while(@lookahead.type == Token::WS)
        	@lookahead = nextToken()
      	end
   	end
  	
	# Compare two different Tokens
	def match(dtype)
      	if (@lookahead.type != dtype)
        	puts "Expected #{dtype} found #{@lookahead.text}"
			$errorCount += 1
      	end
      	consume()				# Iterate to Next Token
   	end
   	
	
	# Begin reading PGM Rule and Parse
	def program()
      	while( @lookahead.type != Token::EOF)
        	puts "Entering STMT Rule"
			statement()			# Enter STMT Rule			
    	end
		puts "There were #{$errorCount} parse errors found."
   	end
	
	# Read STMT Rule
	def statement()
		if (@lookahead.type == Token::PRINT)
			puts "Found PRINT Token: #{@lookahead.text}"
			match(Token::PRINT)	# Compare lookahead with Token::PRINT
			exp()				# Enter EXP Rule
		else
			assign()			# Enter ASSIGN Rule
		end
		
		puts "Exiting STMT Rule"
	end

	# Read ASSGN Rule
	def assign()
		puts "Entering ASSGN Rule"
		id()					# Enter ID Token
		if ( @lookahead.type == Token::ASSGN)
			puts "Found ASSGN Token: ="
		end
		match(Token::ASSGN)	# Compare lookahead with Token::ASSGN
		exp()					# Enter EXP Rule
		puts "Exiting ASSGN Rule"   
	end
	
	# Read EXP Rule
	def exp()
		puts "Entering EXP Rule"
		term()					# Enter TERM Rule
		puts "Exiting EXP Rule"
		if (@lookahead.type == Token::RPAREN)
		    puts "Found RPAREN Token: #{@lookahead.text}"
		    consume()			# Iterate to Next Token
		end
	end

	# Read ETAIL Rule
	def etail()
		puts "Entering ETAIL Rule"
        if (@lookahead.type == Token::ADDOP)
            puts "Found ADDOP Token: #{@lookahead.text}"
            consume()			# Iterate to Next Token
            term()				# Enter TERM Rule
        elsif (@lookahead.type == Token::SUBOP)
            puts "Found SUBOP Token: #{@lookahead.text}"
            consume()			# Iterate to Next Token
            term()				# Enter TERM Rule
        else
            puts"Did not find ADDOP or SUBOP Token, choosing EPSILON production"
        end
		puts "Exiting ETAIL Rule"
    end

	# Read TERM Rule
	def term()
		puts "Entering TERM Rule"
        factor()				# Enter FACTOR Rule
        puts "Exiting TERM Rule"
        etail()					# Enter ETAIL Rule
    end

	# Read TTAIL Rule
	def ttail()
		puts "Entering TTAIL Rule"
        if (@lookahead.type == Token::MULTOP)
            puts "Found MULTOP Token: #{@lookahead.text}"
            consume()			# Iterate to Next Token
            factor()			# Enter FACTOR Rule
        elsif (@lookahead.type == Token::DIVOP)
            puts "Found DIVOP Token: #{@lookahead.text}"
            consume()			# Iterate to Next Token
            factor()			# Enter FACTOR Rule
        else
            puts "Did not find MULTOP or DIVOP Token, choosing EPSILON production"
        end
		puts "Exiting TTAIL Rule"
    end

	# Read FACTOR Rule
	def factor()
        puts "Entering FACTOR Rule"
        if (@lookahead.type == Token::ID)
            id() 				# Enter ID Token
        elsif (@lookahead.type == Token::INT)
            int()				# Enter INT Token
        elsif (@lookahead.type == Token::LPAREN)
            puts "Found LPAREN Token: #{@lookahead.text}"
            consume()			# Iterate to Next Token
            exp()				# Enter EXP Rule
        else
            puts "Expected ( or INT or ID found #{@lookahead.text}"
            $errorCount += 1
            consume()			# Iterate to Next Token
        end
        puts "Exiting FACTOR Rule"
        ttail()
    end

	# Find ID Token
	def id()
        if (@lookahead.type == Token::ID)
            puts "Found ID Token: #{@lookahead.text}"
        end
        match(Token::ID)
    end

	# Find INT Token
	def int()
		if (@lookahead.type == Token::INT)
		  puts "Found INT Token: #{@lookahead.text}"
		  match(Token::INT)
		end
	end

end