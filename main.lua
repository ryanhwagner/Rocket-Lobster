print ( "hello" )

MOAISim.openWindow ( "Penyo Restaurant", 480, 320 )

VIEW_W = 480
VIEW_H = 320

viewport = MOAIViewport.new ()
viewport:setScale ( 480, 320 )
viewport:setSize ( VIEW_W, VIEW_H )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

-- insert bg

bgGfx = MOAIGfxQuad2D.new ()
bgGfx:setTexture ( "assets/images/background.png" )
bgGfx:setRect ( -VIEW_W/2, -VIEW_H/2, VIEW_W/2, VIEW_H/2 )
   
base = MOAIProp2D.new ()
base:setDeck ( bgGfx )
base:setLoc ( 0, 0 )

layer:insertProp ( base )


-- insert order
ORDER_W = 128
ORDER_H = 160

orderGfx = MOAIGfxQuad2D.new ()
orderGfx:setTexture ( "assets/images/order.png" )
orderGfx:setRect ( -ORDER_W/2, -ORDER_H/2, ORDER_W/2, ORDER_H/2 )

order_count = 0

function makeOrder ()
  order_count = order_count + 1

  local start_x = VIEW_W+ORDER_W/2
  local start_y = 70
  local end_x = -VIEW_W/2+order_count*110-30
  local end_y = start_y



  local order = MOAIProp2D.new ()
  order:setDeck ( orderGfx )
  order:setLoc ( start_x, start_y )
  layer:insertProp ( order )

  function order:main ()
    MOAIThread.blockOnAction ( self:seekLoc ( end_x, end_y, 5.0, MOAIEaseType.LINEAR ))
  end

  order.thread = MOAIThread.new ()
  order.thread:run ( order.main, order )

end

mainThread = MOAIThread.new ()
mainThread:run (
  function ()
    local frames = 0
    makeOrder()
    while order_count < 4 do
      coroutine.yield ()
      frames = frames + 1
      if frames >= 90 then
        frames = 0
        makeOrder ()
      end
    end
  end
)