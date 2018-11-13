pragma solidity ^0.4.24;

interface Participant {
    function isPlayer() external returns (bool);
    function totalMoney() external returns (uint);
    function has(address sender) external returns (bool);
    function transferAllTo(Participant _p) external;
}

contract Player is Participant
{
    address public user;

    constructor() public
    {
    }

    function fund() public payable
    {
        
    }

    function isPlayer() external returns (bool)
    {
        return true;
    }

    function totalMoney() external returns (uint)
    {
        return address(this).balance;
    }
    
    function has(address sender) external returns (bool)
    {
        return address(this) == sender;
    }

    function transferAllTo(Participant _p) external
    {
        address(_p).transfer(address(this).balance);
    }
    
    function agreeWon(Game _g)
        public
    {
        _g.agreeWon(this);
    }
    
    function start(Game _game)
    public
    {
        _game.start();
    }
}

contract Team is Participant
{
    Participant p1;
    Participant p2;

    constructor(Participant _p1,
                Participant _p2) public
    {
        p1 = _p1;
        p2 = _p2;
    }
    
    function isPlayer() external returns (bool)
    {
        return false;
    }
    
    function totalMoney() external returns (uint)
    {
        return p1.totalMoney() + p2.totalMoney();
    }

    function has(address sender) external returns (bool)
    {
        return (((p1 != address(0)) && p1.has(sender)) ||
                ((p2 != address(0)) && p2.has(sender)));
    }

    function transferAllTo(Participant _p) external
    {
        require(_p == p1 || _p == p2);
        address(_p).transfer(address(this).balance);
    }
}

contract Game
{
    Participant public p1;
    Participant public p2;
    
    bool public p1Started = false;
    bool public p2Started = false;

    bool public p1SaidP2Won;
    bool public p1SaidP1Won;
    bool public p2SaidP2Won;
    bool public p2SaidP1Won;

    function add(Participant _p)
        public
    {

        if (p1 == address(0)) {
            // if (p2 != address(0)) {
            //     require(!p2.has(msg.sender));
            // }
            p1 = _p;
        }
        else if (p2 == address(0)) {
            // if (p1 != address(0)) {
            //     require(!p1.has(msg.sender));
            // }
            p2 = _p;
        }
        else {
            require(false);
        }
    }

    function start()
        public
    {
        if (!p1Started && p1.has(msg.sender)) {
            p1Started = true;
        }
        if (!p2Started && p2.has(msg.sender)) {
            p2Started = true;
        }
    }

    function gameCanStart()
        public
        view
        returns (bool)
    {
        return p1Started && p2Started;
    }

    function gameOngoing()
        public
        view
        returns (bool)
    {
        return gameCanStart() && !gameDone();
    }

    function gameDone()
        public
        view
        returns (bool)
    {
        return (p1SaidP1Won || p1SaidP2Won ||
                p2SaidP1Won || p2SaidP2Won);
    }

    function playersAgreed()
        public
        view
        returns (bool)
    {
        return ((p1SaidP1Won && p2SaidP1Won) ||
                (p1SaidP2Won || p2SaidP2Won));
    }

    function agreeWon(Participant _p)
        public
    {
        require(_p == p1 || _p == p2);

        if (p1.has(msg.sender)) {
            require(!p1SaidP1Won && !p1SaidP2Won);
            p1SaidP1Won = (_p == p1);
            p1SaidP2Won = (_p == p2);
        }
        else if (p2.has(msg.sender)) {
            require(!p2SaidP1Won && !p2SaidP2Won);
            p2SaidP1Won = (_p == p1);
            p2SaidP2Won = (_p == p2);
        }

        // if (playersAgreed())
        // {
        //     if (p1SaidP1Won) {
        //         p2.transferAllTo(p1);
        //     }
        //     else {
        //         p1.transferAllTo(p2);
        //     }
        // }
    }
}

contract Test
{
    Game public game;
    
    
    function go()
        public
    {
        Player p1 = new Player();
        Player p2 = new Player();
    
        game = new Game();
        game.add(Participant(p1));
        game.add(Participant(p2));
    
        p1.start(game);
        p2.start(game);
    
        p1.agreeWon(game);
        p2.agreeWon(game);
    }
}
