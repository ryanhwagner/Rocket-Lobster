print ( "hello" )

MOAISim.openWindow ( "Penyo Restaurant", 480, 320 )

viewport = MOAIViewport.new ()
viewport:setScale ( 480, 320 )
viewport:setSize ( 480, 320 )

layer = MOAILayer2D.new ()
layer:setViewport ( viewport )
MOAISim.pushRenderPass ( layer )

-- insert bg

bgGfx = MOAIGfxQuad2D.new ()
bgGfx:setTexture ( "assets/images/background.png" )
bgGfx:setRect ( -240, -160, 240, 160 )
   
base = MOAIProp2D.new ()
base:setDeck ( bgGfx )
base:setLoc ( 0, 0 )

layer:insertProp ( base )


-- insert order

orderGfx = MOAIGfxQuad2D.new ()
orderGfx:setTexture ( "assets/images/order.png" )
orderGfx:setRect ( -75, -75, 75, 75 )

function makeRocket ()
  local order = MOAIProp2D.new ()
  order:setDeck ( orderGfx )
  order:setLoc (240+75,75)
  layer:insertProp ( order )

  function order:main ()
    MOAIThread.blockOnAction ( self:seekLoc ( -240+75, 75, 5.0, MOAIEaseType.LINEAR ))
  end

  order.thread = MOAIThread.new ()
  order.thread:run ( order.main, order )

end

makeRocket ()