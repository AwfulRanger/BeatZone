DEFINE_BASECLASS( "gamemode_base" )



GM.VoteData = GM.VoteData or {}
GM.VoteDataNames = GM.VoteDataNames or {}

function GM:AddVoteData( name, data )
	
	data = data or {}
	
	name = tostring( name )
	
	local index
	if self.VoteData[ name ] == nil then
		
		index = table.insert( self.VoteDataNames, name )
		
	else
		
		index = self.VoteData[ name ].Index
		
	end
	
	data.IDName = name
	data.Index = index
	data.Name = data.Name or ( "#" .. name )
	data.Time = data.Time or 30
	data.Ratio = data.Ratio or 0.5
	data.GetDescription = data.GetDescription or function( self, ply ) return self.Description or "" end
	data.GetName = data.GetName or function( self, data ) return self.Name or "" end
	data.GetRatio = data.GetRatio or function( self ) return self.Ratio or 0.5 end
	data.CanCallVote = data.CanCallVote or function( self, ply, data, gm ) end
	data.CanVote = data.CanVote or function( self, ply, vote, data, gm ) end
	data.CallVote = data.CallVote or function( self, data, gm )
		
		gm = gm or gmod.GetGamemode()
		
		if gm:CanCallVote( LocalPlayer(), self, data ) ~= true then return end
		
		gm:SendStartVote( self, data )
		
	end
	data.StartVote = data.StartVote or function( self, ply, data, time, gm ) gm:PlayerVote( ply, true ) end
	data.CreatePanel = data.CreatePanel or function( self, gm ) return vgui.Create( "DPanel" ) end
	data.NetSend = data.NetSend or function( self, data ) end
	data.NetReceive = data.NetReceive or function( self ) return {} end
	data.Finished = data.Finished or function( self, yes, data, gm ) end
	
	self.VoteData[ name ] = data
	
end

function GM:GetVoteData( id )
	
	if isnumber( id ) == true then return self.VoteData[ self.VoteDataNames[ id ] ] end
	
	return self.VoteData[ tostring( id ) ]
	
end

function GM:GetVoteDataCount()
	
	return #self.VoteDataNames
	
end



GM.VotingPlayers = {
	
	Count = 0,
	YesCount = 0,
	NoCount = 0,
	Players = {},
	PlayerIndex = {},
	PlayerVotes = {},
	
}

function GM:ResetVote()
	
	self.Vote = nil
	self.VoteTime = nil
	self.VotePlayer = nil
	self.VoteOptions = nil
	
	self.VotingPlayers = {
		
		Count = 0,
		YesCount = 0,
		NoCount = 0,
		Players = {},
		PlayerIndex = {},
		PlayerVotes = {},
		
	}
	
end

function GM:FinishVote( yes )
	
	if self:IsVote() ~= true then return end
	
	yes = yes or false
	
	local vote = self:GetVote()
	vote:Finished( yes, self.VoteOptions, self )
	
	local ply = self.VotePlayer
	if IsValid( ply ) == true then ply:SetNW2Float( "BZ_LastVote", CurTime() ) end
	
	if SERVER then
		
		net.Start( "BZ_FinishVote" )
			
			net.WriteBool( yes or false )
			
		net.Broadcast()
		
		local name = vote:GetName( self.VoteOptions ) or ""
		local text = name .. " vote failed"
		if yes == true then text = name .. " vote succeeded" end
		PrintMessage( HUD_PRINTTALK, text )
		
	end
	
	self:ResetVote()
	
end

function GM:StartVote( vote, ply, data, time )
	
	if self:IsVote() == true then self:FinishVote() end
	
	self:ResetVote()
	
	self.Vote = vote
	self.VoteTime = time or CurTime()
	self.VotePlayer = ply
	self.VoteOptions = data
	
	vote:StartVote( ply, data, time, self )
	
	if SERVER then
		
		net.Start( "BZ_StartVote" )
			
			net.WriteUInt( vote.Index, 32 )
			net.WriteEntity( ply )
			vote:NetSend( data )
			net.WriteFloat( self.VoteTime )
			
		net.Broadcast()
		
	end
	
end

function GM:GetVote()
	
	return self.Vote
	
end

function GM:IsVote()
	
	return self:GetVote() ~= nil
	
end

function GM:CanCallVote( ply, vote, data )
	
	if self:IsVote() == true then return false end
	
	if IsValid( ply ) == true then
		
		local lastvote = ply:GetNW2Float( "BZ_LastVote", -1 )
		if lastvote ~= -1 and CurTime() < lastvote + 5 then return false end
		
	end
	
	data = data or self.VoteOptions
	
	local cancallvote = vote:CanCallVote( ply, data, self )
	if cancallvote == nil then cancallvote = true end
	
	return cancallvote
	
end



function GM:PlayerGetVote( ply )
	
	return self.VotingPlayers.PlayerVotes[ ply ]
	
end

function GM:PlayerIsVoting( ply )
	
	return self:PlayerGetVote( ply ) ~= nil
	
end

function GM:PlayerVote( ply, vote )
	
	local curvote = self:PlayerGetVote( ply )
	if vote == curvote then return end
	
	local vplys = self.VotingPlayers
	if curvote == true then
		
		vplys.YesCount = vplys.YesCount - 1
		
	elseif curvote == false then
		
		vplys.NoCount = vplys.NoCount - 1
		
	end
	
	if vote == true then
		
		vplys.YesCount = vplys.YesCount + 1
		
	elseif vote == false then
		
		vplys.NoCount = vplys.NoCount + 1
		
	end
	
	vplys.PlayerVotes[ ply ] = vote
	if vote ~= nil then
		
		if vplys.PlayerIndex[ ply ] == nil then
			
			vplys.PlayerIndex[ ply ] = table.insert( vplys.Players, ply )
			vplys.Count = #vplys.Players
			
		end
		
	else
		
		local key = vplys.PlayerIndex[ ply ]
		vplys.PlayerIndex[ ply ] = nil
		table.remove( vplys.Players, key )
		for _, v in pairs( vplys.PlayerIndex ) do if v > key then vplys.PlayerIndex[ _ ] = v - 1 end end
		
		vplys.Count = #vplys.Players
		
	end
	
	if SERVER then
		
		net.Start( "BZ_PlayerVote" )
			
			net.WriteEntity( ply )
			net.WriteBool( vote == nil )
			if vote ~= nil then net.WriteBool( vote ) end
			
		net.Broadcast()
		
	end
	
end

function GM:CanVote( ply, vote )
	
	if self:IsVote() ~= true then return false end
	
	return self:GetVote():CanVote( ply, vote, self ) or true
	
end



function GM:HandleVote()
	
	if SERVER and self:IsVote() == true then
		
		local canvote = 0
		local allvoting = true
		local plys = player.GetAll()
		local plycount = player.GetCount()
		for i = 1, plycount do
			
			local ply = plys[ i ]
			if self:CanVote( ply ) == true then
				
				canvote = canvote + 1
				if self:PlayerIsVoting( ply ) ~= true then allvoting = false end
				
			end
			
		end
		
		if allvoting == true or CurTime() > self.VoteTime + self:GetVote().Time then
			
			local canvoteratio = canvote / plycount
			local yesratio = self.VotingPlayers.YesCount / ( plycount * canvoteratio )
			self:FinishVote( yesratio > self:GetVote():GetRatio() )
			
			return
			
		end
		
	end
	
end



----
--Add vote data
----
GM:AddVoteData( "kick", {
	
	Name = "Kick player",
	Description = "Kick a player from the game",
	GetName = function( self, data )
		
		if data == nil then return self.Name end
		
		local name = ""
		if IsValid( data.player ) == true then name = data.player:Nick() end
		
		return "Kick player \"" .. name .. "\""
		
	end,
	CanCallVote = function( self, ply, data, gm ) if data ~= nil and ( data.player == nil or ply == data.player ) then return false end end,
	StartVote = function( self, ply, data, time, gm )
		
		gm:PlayerVote( ply, true )
		gm:PlayerVote( data.player, false )
		
	end,
	CreatePanel = function( self, gm )
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
		
		local panel = vgui.Create( "DPanel" )
		function panel:Paint( w, h )
		end
		
		local plyscroll = vgui.Create( "DScrollPanel" )
		plyscroll:SetParent( panel )
		plyscroll:Dock( FILL )
		plyscroll:DockMargin( spacing, spacing, spacing, spacing )
		
		local plybuttontall = math.Round( ScrH() * 0.05 )
		
		local plys = player.GetAll()
		local curply = plys[ 1 ]
		local clicked = false
		for i = 1, #plys do
			
			local ply = plys[ i ]
			if ply ~= LocalPlayer() then
				
				local plybutton = gm.HUD:CreateButton( plyscroll, ply:Nick(), function( button ) curply = ply end )
				plybutton:Dock( TOP )
				plybutton:DockMargin( 0, 0, 0, spacing )
				plybutton:SetTall( plybuttontall )
				plybutton:SetFont( "BZ_MenuButtonSmall" )
				function plybutton:GetButtonBGColor()
					
					if curply == ply then return gm.HUD.Color.buttonspecial end
					
				end
				
				if clicked ~= true then
					
					clicked = true
					plybutton:DoClick()
					
				end
				
			end
			
		end
		
		local callvote = gm.HUD:CreateButton( panel, "Start vote", function( button ) self:CallVote( { player = curply } ) end )
		callvote:Dock( BOTTOM )
		callvote:SetTall( ScrH() * 0.1 )
		function callvote.GetButtonBGColor( button )
			
			if gm:CanCallVote( LocalPlayer(), self, { player = curply } ) ~= true then return gm.HUD.Color.buttoninactive, true end
			
		end
		
		return panel
		
	end,
	NetSend = function( self, data ) net.WriteEntity( data.player ) end,
	NetReceive = function( self ) return { player = net.ReadEntity() } end,
	Finished = function( self, yes, data, gm )
		
		if CLIENT then return end
		
		if yes ~= true or data == nil or IsValid( data.player ) ~= true then return end
		
		local reason = "Votekicked"
		if gm ~= nil and IsValid( gm.VotePlayer ) == true then reason = "Votekicked by " .. gm.VotePlayer:Nick() end
		
		data.player:Kick( reason )
		
	end,
	
} )

GM:AddVoteData( "restart", {
	
	Name = "Restart game",
	Description = "Restart the game and reset all progress",
	Ratio = 0.9,
	CreatePanel = function( self, gm )
		
		local panel = vgui.Create( "DPanel" )
		function panel:Paint( w, h )
		end
		
		local callvote = gm.HUD:CreateButton( panel, "Start vote", function( button ) self:CallVote() end )
		callvote:Dock( BOTTOM )
		callvote:SetTall( ScrH() * 0.1 )
		function callvote.GetButtonBGColor( button )
			
			if gm:CanCallVote( LocalPlayer(), self ) ~= true then return gm.HUD.Color.buttoninactive, true end
			
		end
		
		return panel
		
	end,
	Finished = function( self, yes, data, gm )
		
		if CLIENT then return end
		
		if yes == true then gm:RoundLost() end
		
	end,
	
} )

GM:AddVoteData( "changemap", {
	
	Name = "Change map",
	Description = "Change the current map (all progress will be lost)",
	Ratio = 0.9,
	GetName = function( self, data )
		
		if data == nil then return self.Name end
		
		return "Change map to \"" .. ( data.map or "" ) .. "\""
		
	end,
	CanCallVote = function( self, ply, data, gm ) if data ~= nil and ( data.map == nil or game.GetMap() == data.map or gm:GetConfig( "IsValidMap" )[ data.map ] ~= true ) then return false end end,
	CreatePanel = function( self, gm )
		
		local spacing = math.Round( math.min( ScrW(), ScrH() ) * 0.0075 )
		
		local panel = vgui.Create( "DPanel" )
		function panel:Paint( w, h )
		end
		
		local mapscroll = vgui.Create( "DScrollPanel" )
		mapscroll:SetParent( panel )
		mapscroll:Dock( FILL )
		mapscroll:DockMargin( spacing, spacing, spacing, spacing )
		
		local mapbuttontall = math.Round( ScrH() * 0.05 )
		
		local maps = gm:GetConfig( "MapList" )
		local curmap = maps[ 1 ]
		local clicked = false
		for i = 1, #maps do
			
			local map = maps[ i ]
			if map ~= game.GetMap() then
				
				local mapbutton = gm.HUD:CreateButton( mapscroll, map, function( button ) curmap = map end )
				mapbutton:Dock( TOP )
				mapbutton:DockMargin( 0, 0, 0, spacing )
				mapbutton:SetTall( mapbuttontall )
				mapbutton:SetFont( "BZ_MenuButtonSmall" )
				function mapbutton:GetButtonBGColor()
					
					if curmap == map then return gm.HUD.Color.buttonspecial end
					
				end
				
				if clicked ~= true then
					
					clicked = true
					mapbutton:DoClick()
					
				end
				
			end
			
		end
		
		local callvote = gm.HUD:CreateButton( panel, "Start vote", function( button ) self:CallVote( { map = curmap } ) end )
		callvote:Dock( BOTTOM )
		callvote:SetTall( ScrH() * 0.1 )
		function callvote.GetButtonBGColor( button )
			
			if gm:CanCallVote( LocalPlayer(), self, { map = curmap } ) ~= true then return gm.HUD.Color.buttoninactive, true end
			
		end
		
		return panel
		
	end,
	NetSend = function( self, data ) net.WriteString( data.map ) end,
	NetReceive = function( self ) return { map = net.ReadString() } end,
	Finished = function( self, yes, data, gm )
		
		if CLIENT then return end
		
		if yes == true and data ~= nil and data.map ~= nil and data.map ~= "" then RunConsoleCommand( "changelevel", data.map ) end
		
	end,
	
} )