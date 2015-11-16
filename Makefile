README.bbcode: README.md pandoc-bbcode-phpbb.lua
	pandoc -f markdown+pipe_tables -t pandoc-bbcode-phpbb.lua -o $@ --smart $<
