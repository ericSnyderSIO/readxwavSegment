global HANDLES REMORA PARAMS

% Remora label under Triton's "Remoras" menu option
REMORA.readSeg.menu = uimenu(HANDLES.remmenu, 'Label', 'Read xwav Segment', ...
    'Enable','on','Visible','on');

% First sub-menu option: Maxe a new xwav look-up table
uimenu(REMORA.readSeg.menu, 'Label', 'Make xwav look-up table for a HARP', ...
    'Callback', 'main(''makeTable'')');

% Second sub-menu option: update look-up table with new drive paths
uimenu(REMORA.readSeg.menu, 'Label', 'Update drive path(s) for a HARP', ...
    'Callback', 'main(''updateDrives'')');

% maybe add third to use loadxwavSegment with a GUI? I don't know why anyone
% would want that, though

REMORA.savePath = 'c:/'; % initialize a default save path 