-module(erlycaptcha).
-compile(export_all).

new(Prefix, Len, LineNum) ->
    Code = generate_rand(Len),
    FileName = Prefix++"_"++Code,

    File = io_lib:format("./captcha/~s.png",[FileName]),
    filelib:fold_files("./captcha", io_lib:format("~s_.{~p}\.png", [Prefix, Len]), false, fun(F, Acc)-> file:delete(F), [F | Acc] end, []),
    
    Lines = lists:foldl(fun(_I, Acc) -> 
    	Acc ++  io_lib:format("Line ~p,0 ~p,100", [random:uniform(100), random:uniform(100)]) ++ " "
    end, "", lists:seq(1, LineNum)),
    
    Cmd = io_lib:format("convert -background '#FFFFFF' -fill '#000000' -size 100 -gravity Center -wave 5x100 -swirl 15 -font DejaVu-Serif-Book -pointsize 28 label:~s -draw '~s' ~s", [Code, Lines,File]),
    os:cmd(Cmd),

    {ok, BinPng} = file:read_file(File),
 
    BinPng.

check(Prefix, Code) ->
	FileName = Prefix++"_"++Code,
    File = io_lib:format("./captcha/~s.png",[FileName]),
    
	Res = filelib:is_regular(File),
	file:delete(File),
	Res.

generate_rand(Length) ->
	{A1,A2,A3} = now(),
    random:seed(A1, A2, A3),
    lists:foldl(fun(_I, Acc) -> 
    	Chars = "abcdefghijklmnopqrstuvwxyz0123456789",
    	Char = string:substr(Chars, random:uniform(length(Chars)), 1),
    	Char ++ Acc 
    end, "", lists:seq(1, Length)).


