set -e
cmd="$@"
until pg_isready -h "postgres" -p "5432"
do
    sleep 1
done
# sleep here needed because postgres in docker starts twice
sleep 2
exec $cmd
