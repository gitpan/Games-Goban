use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'		=> 'Games::Goban',
    'VERSION_FROM'	=> 'lib/Games/Goban.pm', # finds $VERSION
    'PREREQ_PM'		=> {}, # e.g., Module::Name => 1.1
);
