require 'gosu'

class Money_Hands < Gosu:: Window
    def initialize
        super 1280, 960
        self.caption = "Money Hands"

        @background_image = Gosu::Image.new("background.png", :tileable => true)
        @player = Player.new
        @player.warp(640,480)
        @money = Array.new
        @big_money = Array.new
        @font = Gosu::Font.new(20)
        @bombs = Array.new
        @death = Gosu::Sample.new("death.mid")
        @played = false
    end

    def update
        if @player.dead != true
            if Gosu.button_down? Gosu::KB_LEFT or Gosu::button_down? Gosu::GP_LEFT
                @player.accelerate
                @player.move_left
            end
            if Gosu.button_down? Gosu::KB_RIGHT or Gosu::button_down? Gosu::GP_RIGHT
                @player.accelerate
                @player.move_right
            end

            @player.collect_money(@money)
            @player.collect_big_money(@big_money)
            @player.die_to_bombs(@bombs)
            
            if rand(100) < 4 and @money.size < 10
                @money.push(Bill.new)
            end

            if rand(100) < 3 and @big_money.size < 3
                @big_money.push(Big_Bill.new)
            end

            if @bombs.size < 1
                @bombs.push(Bomb.new)
            end

            @money.each { |bill| bill.move}
            @money.each do |bill|
                if bill.y > 960
                    @money.delete(bill)
                end
            end

            @big_money.each { |big_bill| big_bill.move}
            @big_money.each do |big_bill|
                if big_bill.y > 960
                    @big_money.delete(big_bill)
                end
            end

            @bombs.each { |bomb| bomb.move}
            @bombs.each do |bomb|
                if bomb.y > 960
                    @bombs.delete(bomb)
                end
            end
        else
            if @played == false
                @death.play
                @played = true
            end
            if Gosu.button_down? Gosu::KB_SPACE
                initialize
            end
        end
    end

    def draw
            @background_image.draw(0, 0, ZOrder::BACKGROUND)
            @player.draw
            @money.each { |bill| bill.draw }
            @big_money.each { |big_bill| big_bill.draw }

            @bombs.each {|bomb| bomb.draw }
        if @player.dead == true
            @font.draw("DEATH", 540, 430, ZOrder::UI, 5.0, 5.0, Gosu::Color::RED)
            @font.draw("Restart by pressing: 'Space Bar'", 400, 500, ZOrder::UI, 3.0, 3.0, Gosu::Color::RED)
        end
        @font.draw("Account: $#{@player.score}", 10, 10, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @font.draw("Lives:  #{@player.lives}", 10, 30, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
    end

    def button_down(id)
        if id == Gosu::KB_ESCAPE
            close
        else
            super
        end
    end
end

class Player
    attr_reader :lives, :dead
    def initialize
        @image = Gosu::Image.new("mario.png")
        @x = @y = @vel_x = 0.0
        @score =  0
        @lives = 3
        @dead = false
        @font = Gosu::Font.new(10)
    end

    def warp(x, y)
        @x, @y = x, y
    end

    def move_left
        @x -= @vel_x
        @x %= 1280
        @vel_x *= 0.95
    end

    def move_right
        @x += @vel_x
        @x %= 1280
        @vel_x *= 0.95
    end

    def accelerate
        @vel_x += 0.5
    end

    def draw
        @image.draw(@x- @image.width / 2.0, 775 - @image.height / 2.0, ZOrder::UI, 1, 1)
    end

    def score
        @score
    end

    def collect_money(money)
        money.reject!  do |bill|
            if Gosu.distance(@x, 725, bill.x, bill.y) < 50
                @score += 5
                true
            else
                false
            end
        end
    end

    def collect_big_money(big_money)
        big_money.reject!  do |big_bill|
            if Gosu.distance(@x, 725, big_bill.x, big_bill.y) < 50
                @score += 10
                true
            else
                false
            end
        end
    end

    def die_to_bombs(bombs)
        bombs.reject!  do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 35
                @lives -= 1
            end    
        end
        if @lives <= 0
            @dead = true
        end
    end
end

module ZOrder
    BACKGROUND, MONEY, UI = *0..3
end

class Bill
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("smallbill.png")
        @x = rand * 1280
        @y = 0
        @vel_y = 3
    end

    def move
        @y += @vel_y
    end

    def draw
        @image.draw(@x - @image.width / 2.0, @y - @image.height / 2.0, ZOrder::MONEY, 1, 1)
    end
end

class Big_Bill
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("bigbill.png")
        @x = rand * 1280
        @y = 0
        @vel_y = 6
    end

   def move
        @y += @vel_y
    end 

    def draw
        @image.draw(@x - @image.width / 2.0, @y - @image.height / 2.0, ZOrder::MONEY, 1, 1)
    end
end

class Bomb
    attr_reader :x, :y

    def initialize
        @image = Gosu::Image.new("bomb.jpg")
        @x = rand * 1280
        @y = 0
        @vel_y = 9
    end

    def move
        @y += @vel_y
    end

    def draw  
        @image.draw(@x - @image.width / 2.0, @y - @image.height / 2.0, ZOrder::MONEY, 1, 1)
    end
end
Money_Hands.new.show