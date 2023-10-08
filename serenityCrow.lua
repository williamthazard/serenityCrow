---serenityCrow
s = sequins
notes = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}}
shufflers = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}}
durShuffler = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12}}
jf_pitch = {1,2,3,4,5,6}
jf_trig = {1,2,3,4,5,6}
w_event = {1,2,3,4}
w_times = {0.25,0.5,0.75,1,1.25,1.75,2}
updaters = {16,32,64,128,256}
durTables = {{8},{4},{2,2,4},{2},{1,1,2},{1},{0.5,7.5},{0.5,3.5},{0.5,1.5},{0.5},{0.25},{7.5,7.5,1},{6,2,2,6},{5.5,5.5,2,3},{4.5,4.5,4,3},{4,2,1,1}}
function shuffle(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end
for i=1,10 do
    notes[i] = s(shuffle({32,37,39,44,49,51,56,61,63,66,68,73,75,80,85,87}))
end
for i=1,10 do
    shufflers[i] = function()
        while true do
            clock.sync(updaters[math.random(5)])
            shuffle(notes[i])
        end
    end
end
for i=1,16 do
    durShuffler[i] = function()
        while true do
            clock.sync(updaters[math.random(5)])
            if #durTables[i] > 1 then
                shuffle(durTables[i])
                print('shuffling note duration sequence ',i)
            end
        end
    end
end
function bigDurShuffler()
    while true do
        clock.sync(updaters[math.random(5)])
        shuffle(durTables)
        print('shuffling note duration sequences')
    end
end
function wShuffler()
    while true do
        clock.sync(updaters[math.random(5)])
        shuffle(w_times)
        ii.wsyn.lpg_time(-1*clock.get_beat_sec()*w_times[1])
        print('wsyn lpg time set to ',-1*clock.get_beat_sec()*w_times[1])
    end
end
for i=1,6 do
    jf_pitch[i] = function()
        while true do
            clock.sync(s(durTables[i])()*4)
            ii.jf.pitch(i,(s(notes[i])()-60)/12)
        end
    end
    jf_trig[i] = function()
        while true do
            clock.sync(s(durTables[i+6])()*4)
            ii.jf.vtrigger(i,math.random(5))
            print('playing jf voice ',i)
        end
    end
end
for i=1,4 do
    w_event[i] = function()
        while true do
            clock.sync(s(durTables[i+12])()*4)
            ii.wsyn.play_voice(i,s(notes[i+6])()-60/12,math.random(5))
            print('playing wsyn voice ',i)
        end
    end
end
function init()
    input[1].mode('clock')
    for i=1,4 do
        output[i](lfo(clock.get_beat_sec()*i*256))
    end
    ii.jf.mode(1)
    ii.jf.run_mode(1)
    ii.wsyn.curve(0)
    ii.wsyn.ramp(0)
    ii.wsyn.fm_index(1)
    ii.wsyn.fm_env(0)
    ii.wsyn.fm_ratio(1)
    ii.wsyn.lpg_time(-1*clock.get_beat_sec())
    ii.wsyn.lpg_symmetry(1)
    ii.wsyn.patch(1,1)
    ii.wsyn.patch(2,2)
    for i=1,16 do
        clock.run(durShuffler[i])
    end
    for i=1,10 do
        clock.run(shufflers[i])
    end
    for i=1,6 do
        clock.run(jf_pitch[i])
        clock.run(jf_trig[i])
    end
    for i=1,4 do
        clock.run(w_event[i])
    end
    clock.run(bigDurShuffler)
    clock.run(wShuffler)
end