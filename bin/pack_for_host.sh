# 注意修改 oh-my-env 目录名为你的目录名
dir=oh-my-env

time=$(date +'%Y%m%d-%H%M%S')
dist=tmp/mangosteen-$time.tar.gz # 当前打包目录
current_dir=$(dirname $0) # 当前shell脚本所在目录
deploy_dir=/workspaces/$dir/mangosteen_deploy # 当前docker的共享目录路径，此目录的内外环境文件同步

yes | rm tmp/mangosteen-*.tar.gz; # 若已打过包则先删除之前的
yes | rm $deploy_dir/mangosteen-*.tar.gz; 

tar --exclude="tmp/cache/*" -czv -f $dist * # 打包所有非.文件 和 非/tmp/cache路径下的文件到
mkdir -p $deploy_dir
cp $current_dir/../config/host.Dockerfile $deploy_dir/Dockerfile
cp $current_dir/setup_host.sh $deploy_dir/
mv $dist $deploy_dir
echo $time > $deploy_dir/version
echo 'DONE!'