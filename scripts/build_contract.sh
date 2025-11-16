cd ../musicatcontract

echo "Running tests for Musicat contract..."
npx hardhat test
echo "Tests completed.✅"
echo "Building Musicat contract..."
npx hardhat build
npx hardhat compile
echo "Build completed.✅"

echo "Copying build artifacts to the scripts directory..."



