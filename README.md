# Test Instructions

#### Step 1: Install and Start Docker in the Server
```bash
sudo apt-get update
sudo apt-get install -y docker.io docker-compose
sudo service docker start
```

#### Step 2: Start Jenkins Server
```bash
cd ~/webpage_ws
bash start_jenkins.sh
cat /home/user/jenkins__pid__url.txt
```

#### Step 3: Login to Jenkins Server
- Go to the web adress displayed by the last command.
- User: admin
- Password: miguel

#### Step 4: Test CI
- Send to the student the output of the following command:
```bash
echo "$(jenkins_address)github-webhook/"
```
- Create a pull request to the following repository https://github.com/MiguelSolisSegura/ros2_ci.git


