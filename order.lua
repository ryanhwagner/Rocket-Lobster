-- insert order

ORDER_W = 128
ORDER_H = 160

orderGfx = MOAIGfxQuad2D.new ()
orderGfx:setTexture ( "assets/images/order.png" )
orderGfx:setRect ( -ORDER_W/2, -ORDER_H/2, ORDER_W/2, ORDER_H/2 )

Order = {count = 0; id = 0; orders = {}}

function Order.remove (self, _id)
  self.orders[_id] = nil
  self.count = self.count - 1

  -- tell other orders to move
  local i = 0
  for id, o in pairsByKeys(self.orders) do
    i = i + 1
    --o.thread:run ( o:move(o:getLocation(i)), o )
    o:move(o:getLocation(i))
  end
end

function Order.new (self)
  if ding then 
    ding:play ()
  end

  self.count = self.count + 1
  self.id = self.id + 1

  self.orders[self.id] = MOAIProp2D.new ()
  self.orders[self.id].id = self.id
  local order = self.orders[self.id]

  local start_x = VIEW_W+ORDER_W/2
  local start_y = 70
  local end_y = start_y

  --local order = MOAIProp2D.new ()
  order:setDeck ( orderGfx )
  order:setLoc ( start_x, start_y )
  layer:insertProp ( order )

   
  order.textbox = MOAITextBox.new ()
  order.textbox:setColor(99,99,99)
  order.textbox:setFont ( font )
  order.textbox:setTextSize ( 20 )
  order.textbox:setRect ( -20, -20, 20, 20 )
  order.textbox:setYFlip ( true )
  order.textbox:setString ( "" .. self.id )
  order.textbox:setAttrLink (MOAIProp2D.ATTR_X_LOC, order, MOAIProp2D.ATTR_X_LOC)
  order.textbox:setAttrLink (MOAIProp2D.ATTR_Y_LOC, order, MOAIProp2D.ATTR_Y_LOC)
  order.textbox:setPriority(1)
  orderContentLayer:insertProp (order.textbox)


  function order:main ()
    self:move(self:getLocation(Order.count))
  end

  function order:remove ()
    Order:remove(self.id)
    layer:removeProp ( self )
    orderContentLayer:removeProp ( self.textbox)
  end

  function order:move(target_x,speed)
    if self.anim then
      self.anim:stop()
    end

    local target_y = end_y
    local speed = speed or 100
    local travelDist = distance ( start_x, start_y, target_x, target_y )
    local travelTime = travelDist / speed
    
    --MOAICoroutine.blockOnAction ( self:seekLoc ( target_x, target_y, travelTime, MOAIEaseType.LINEAR ))
    self.anim = self:seekLoc ( target_x, target_y, travelTime, MOAIEaseType.EASE_IN )
  
  end

  function order:getLocation (ind)
    return -VIEW_W/2+ind*110-30
  end

  function order:gotoTarget (speed)
    local i = 0
    for id, o in pairsByKeys(Order.orders) do
      i = i + 1
      if(o == self) then
        --o.thread:run ( o:move(o:getLocation(i)), o )
        o:move(o:getLocation(i),speed)
      end
    end
  end

  -- order.thread = MOAICoroutine.new ()
  -- order.thread:run ( order.main, order )

  order:main()
end