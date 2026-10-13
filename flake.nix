{
  description = "ARM macOS Node.js and MongoDB Dev Environment with Auto-Start Database";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-darwin"; 
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; 
      };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nodejs_22   
          mongodb-ce  
          mongosh     
        ];

                       shellHook = ''
          # Absolute path setup
          PRJDIR=$(pwd)
          export MONGDATADIR="$PRJDIR/.mongodb/data"
          export MONGLOGDIR="$PRJDIR/.mongodb/log"
          export MONGPIDFILE="$PRJDIR/.mongodb/mongod.pid"
          
          mkdir -p "$MONGDATADIR" "$MONGLOGDIR"

          # Start MongoDB cleanly in the background without breaking the terminal prompt
          if [ ! -f "$MONGPIDFILE" ] || ! kill -0 $(cat "$MONGPIDFILE") 2>/dev/null; then
            echo "Starting MongoDB database engine..."
            
            # Use nohup and direct output streams to safely fork onto macOS
            nohup mongod --dbpath "$MONGDATADIR" --bind_ip 127.0.0.1 > "$MONGLOGDIR/mongod.log" 2>&1 &
            
            # Capture the background PID immediately
            echo $! > "$MONGPIDFILE"
            
            # Give the database a brief window to initialize its socket
            sleep 1
          else
            echo "MongoDB is already running (PID: $(cat $MONGPIDFILE))."
          fi
          
          # Clean up hook when exiting the shell env
          cleanup_mongo() {
            if [ -f "$MONGPIDFILE" ]; then
              PID=$(cat "$MONGPIDFILE")
              echo "Shutting down local MongoDB instance (PID: $PID)..."
              kill "$PID" 2>/dev/null
              rm -f "$MONGPIDFILE"
            fi
          }
          trap cleanup_mongo EXIT

          echo "========================================="
          echo " 🍏 Apple Silicon Dev Shell Active"
          echo " Node.js: $(node --version)"
          echo " npm:     $(npm --version)"
          echo " MongoDB running on 127.0.0.1:27017"
          echo "========================================="
        '';

                };
    };
}

