-- Prosody IM
-- Copyright (C) 2008-2010 Matthew Wild
-- Copyright (C) 2008-2010 Waqas Hussain
-- Copyright (C) 2014 Daurnimator
--
-- This project is MIT/X11 licensed. Please see the
-- COPYING file in the source package for more information.
--

local function get_hidden(room)
	return room._data.hidden;
end

local function set_hidden(room, hidden)
	hidden = hidden and true or nil;
	if get_hidden(room) == hidden then return false; end
	room._data.hidden = hidden;
	if room.save then room:save(true); end
	return true;
end

module:hook("muc-config-form", function(event)
	table.insert(event.form, {
		name = "muc#roomconfig_publicroom";
		type = "boolean";
		label = "Make Room Publicly Searchable?";
		value = not get_hidden(event.room);
	});
end);

module:hook("muc-config-submitted", function(event)
	local new = event.fields["muc#roomconfig_publicroom"];
	if new ~= nil and set_hidden(event.room, not new) then
		event.status_codes["104"] = true;
	end
end);

module:hook("muc-disco#info", function(event)
	event.reply:tag("feature", {var = get_hidden(event.room) and "muc_hidden" or "muc_public"}):up();
end);

return {
	get = get_hidden;
	set = set_hidden;
};
