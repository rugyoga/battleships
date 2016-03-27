
# Design a 1 player command line battleship game that plays against an AI player, with the
# following rules:
# The game should have both boards set up automatically, users do not place their pieces
# Users take turns entering coordinates
# Board size - 10x10
# Ships are:
#  - Aircraft, 5
#  - Battleship, 4
#  - Submarine, 3
#  - Destroyer, 3
#  - Patrol boat, 2

class Battleships
  SIZE=10
  BLANK='-'
  HIT='*'
  MISS='o'
  SHIPS=[["A", 5],["B", 4],["S", 3],["D", 3],["P", 2]]

  def initialize( player )
    @first  = player == "first"
    @board  = Array.new(SIZE) { Array.new(SIZE) }
    @placed = Array.new(SIZE) { Array.new(SIZE) }
    @ships  = {}
    @moves  = []
    place_pieces
  end

  def fit?( x, y, n, xd, yd )
    i = 0
    while i < n && @board[x][y].nil? do
      x += xd
      y += yd
      i += 1
    end
    i == n
  end

  def insert( name, x, y, n, xd, yd )
    i = 0
    while i < n do
      @board[x][y] = name
      (@ships[name] ||= []) << [x,y]
      x += xd
      y += yd
      i += 1
    end
  end

  def place_rand( vertical, length )
    r = [Random.rand( SIZE ), Random.rand( SIZE-length )]
    vertical ? r : r.rotate
  end

  def place( name, length )
    vertical  = [true,false].sample
    x, y      = place_rand( vertical, length )
    xd, yd    = vertical ? [0,1] : [1,0]
    if fit?( x, y, length, xd, yd )
      insert( name, x, y, length, xd, yd )
    else
      place( name, length )
    end
  end

  def place_pieces
    SHIPS.each{ |n,l| place( n, l ) }
  end

  def display_board( board )
    SIZE.times do |y|
      line = (0..(SIZE-1)).to_a.map do |x|
        s = board[x][SIZE-y-1]
        s.nil? ? BLANK : s
      end.join( '' )
      stderr( line )
    end
  end

  def display_ships
    @ships.each do |name, coordinates|
      stderr( "#{name}: #{coordinates.inspect}" )
    end
  end

  def display
    stderr( "Ours: " )
    display_board( @board )
    display_ships
    stderr( "Theirs: " )
    display_board( @placed )
  end

  def get_line
    $stdin.gets.chomp
  end

  def stderr( s )
    $stderr.puts( s )
  end

  def stdout( s )
    $stdout.puts( s )
  end

  def read_coords
    get_line.split.map( &:to_i )
  end

  def random_coords
    [Random.rand(SIZE), Random.rand(SIZE)]
  end

  def pick_random_square
    x, y = random_coords
    until @placed[x][y].nil?
      x, y = random_coords
    end
    [x, y]
  end

  def valid_sample( xys )
    xys.select{ |x,y| x >= 0 && y >= 0 && x < SIZE && y < SIZE && @placed[x][y].nil? }.sample
  end

  def pick_initial( xy )
    x, y = xy
    valid_sample( [[x+1,y],[x-1,y],[x,y+1],[x,y-1]] )
  end

  def pick_continuation( hits )
    x_diff = hits[0][0] - hits[1][0]
    y_diff = hits[0][1] - hits[1][1]
    if x_diff == 0
      x_first = hits[0][0]
      run = hits.take_while{ |x,y| x == x_first }
      valid_sample( [[x_first, run.first[1]-1], [x_first, run.last[1]+1]] )
    else
      y_first = hits[0][1]
      run = hits.take_while{ |x,y| y == y_first }
      valid_sample( [[run.first[0]-1, y_first], [run.last[0]+1, y_first]] )
    end
  end

  def pick_next_hit( hits )
    if hits.size == 1
      pick_initial( hits.first )
    else
      pick_continuation( hits.sort )
    end
  end

  def pick_move
    hits = @moves.select{ |result, xy| result != MISS }
    if hits.empty? || hits.last.first != HIT
      pick_random_square
    else
      pick_next_hit( hits.reverse.take_while{ |result, xy| result == HIT }.map( &:last ) )
    end
  end

  def make_move( xy )
    stderr( "My move: " )
    stdout( xy.join( ' ' ) )
    stderr( "Result? " )
    hit_or_miss = get_line
    @placed[xy[0]][xy[1]] = hit_or_miss
    @moves << [hit_or_miss, xy]
    hit_or_miss
  end

  def make_moves
    move = make_move( pick_move )
    while move == HIT do
      move = make_move( pick_move )
    end
    make_moves unless move == MISS || won
  end

  def lost
    @ships.values.all?( &:empty? )
  end

  def won
    @moves.select{ |result, xy| result != HIT && result != MISS }.size == 5
  end

  def finished
    lost || won
  end

  def opponents_move
    stderr( "Your move? " )
    x, y = read_coords
    until @board[x][y].nil? do
      ship = @board[x][y]
      left = @ships[ship]
      left.delete( [x,y] )
      @board[x][y] = HIT
      stderr( "Result: " )
      stdout( left.empty? ? ship[0] : HIT )
      return if finished
      stderr( "Your move? " )
      x, y = read_coords
    end
    @board[x][y] = MISS
    stderr( "Result: " )
    stdout( MISS )
  end

  def play
    i = 0
    STDOUT.sync = true
    STDERR.sync = true
    make_moves if @first
    until won do
      display
      opponents_move
      break if lost
      make_moves
      i += 1
    end
    display
    if lost
      stderr( "You won! You are a worthy adversary." )
    else
      stderr( "You lost. Better luck next time!" )
    end
  end
end

Battleships.new( ARGV[0] || "first" ).play
