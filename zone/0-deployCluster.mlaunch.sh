# Deploy cluster using mlaunch.
# https://rueckstiess.github.io/mtools/install.html
# https://rueckstiess.github.io/mtools/mlaunch.html

# Deploys a Sharded Cluster with 2 shards.
# Single-node replica sets are specified for both shards as well as the CSRS.
mlaunch --replicaset --nodes 1 --sharded 2 --config 1 --binarypath $HOME/.local/m/versions/8.0.8-ent/bin

echo
echo "Done. To list processes:"
echo "  mlaunch list --startup"
echo

echo "MongoDB data files are stored in ./data."
echo

