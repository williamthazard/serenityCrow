---serenityCrow
s = sequins
notes = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}}
pitchseq = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}}
shufflers = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10}}
jf_pitch = {1,2,3,4,5,6}
jf_trig = {1,2,3,4,5,6}
w_event = {1,2,3,4}
updaters = {16,32,64,128,256}
durTables = {{8},{4},{2,2,4},{2},{1,1,2},{1},{0.5,7.5},{0.5,3.5},{0.5,1.5},{0.5},{0.25},{7.5,7.5,1},{6,2,2,6},{5.5,5.5,2,3},{4.5,4.5,4,3},{4,2,1,1}}
durseq = {{1},{2},{3},{4},{5},{6},{7},{8},{9},{10},{11},{12},{13},{14},{15},{16}}
function shuffle(tbl)
    for i = #tbl, 2, -1 do
      local j = math.random(i)
      tbl[i], tbl[j] = tbl[j], tbl[i]
    end
    return tbl
end
for i=1,10 do
    notes[i] = shuffle({32,37,39,44,49,51,56,61,63,66,68,73,75,80,85,87})
    pitchseq[i] = s(notes[i])
end
for i=1,16 do
    durseq[i] = s(durTables[i])
end
for i=1,10 do
    shufflers[i] = function()
        while true do
            clock.sync(updaters[math.random(5)])
            shuffle(notes[i])
            pitchseq[i] = s(notes[i])
            print('shuffling pitch sequence ',i)
            if i == 1 then
                shuffle(durTables)
                for j=1,16 do
                    shuffle(durTables[i])
                    durseq[i] = s(durTables[i])
                end
                print('shuffling note duration sequences')
            end
        end
    end
end
function runner()
    while true do
        clock.sync(durseq[math.random(#durTables)]())
        local runvolts = math.random(-5,5)
        ii.jf.run(runvolts)
        print(runvolts,' volts sent to jf run jack')
    end
end
function w_changer()
    while true do
        clock.sync(durseq[math.random(#durTables)]())
        local fmNum = math.random(2)
        local fmDen = math.random(2)
        ii.wsyn.fm_ratio(fmNum,fmDen)
        print('wsyn fm numerator set to ',fmNum)
        print('wsyn fm denominator set to ',fmDen)
    end
end
function w_timer()
    while true do
        clock.sync(durseq[math.random(#durTables)]())
        local time = math.random(-5,5)
        local symmetry = math.random(-5,5)
        ii.wsyn.lpg_time(clock.get_beat_sec()/time)
        ii.wsyn.lpg_symmetry(symmetry)
        print('wsyn lpg time set to ',time)
        print('wsyn lpg symmetry set to ',symmetry)
    end
end
for i=1,6 do
    jf_pitch[i] = function()
        while true do
            clock.sync(durseq[i]())
            ii.jf.pitch(i,(pitchseq[i]()-60)/12)
            print('updating jf voice ',i,' pitch')
        end
    end
    jf_trig[i] = function()
        while true do
            clock.sync(durseq[i+6]())
            ii.jf.vtrigger(i,math.random(5))
            print('triggering jf voice ',i)
        end
    end
end
for i=1,4 do
    w_event[i] = function()
        while true do
            clock.sync(durseq[i+12]())
            ii.wsyn.play_voice(i,(pitchseq[i+6]()-60)/12,math.random(5))
            print('playing wsyn voice ',i)
        end
    end
end
function init()
    clock.tempo = 30
    input[1].mode('clock',1/2)
    for i=1,4 do
        output[i].action = loop{to(5,clock.get_beat_sec()*i*1024),to(-5,clock.get_beat_sec()*i*1024)}
        output[i]()
    end
    ii.jf.mode(1)
    ii.jf.run_mode(1)
    ii.wsyn.ar_mode(1)
    ii.wsyn.curve(0)
    ii.wsyn.ramp(0)
    ii.wsyn.fm_index(1)
    ii.wsyn.fm_env(0)
    ii.wsyn.fm_ratio(1,2)
    ii.wsyn.lpg_time(-1*clock.get_beat_sec()/2)
    ii.wsyn.lpg_symmetry(1)
    ii.wsyn.patch(1,1)
    ii.wsyn.patch(2,2)
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
    clock.run(runner)
    clock.run(w_changer)
    clock.run(w_timer)
end
