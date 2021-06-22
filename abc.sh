customer_array ()
{

select item; do
# Check the selected menu item number
if [ 1 -le "$REPLY" ] && [ "$REPLY" -le $# ];

then
echo "The selected customer is $item"
break;
else
echo "Wrong selection: Select any number from 1-$#"
fi
done
}

# Declare the array
client=('BrightHouse' 'GoldManSachs' 'JM Family' 'Citi Bank')

# Call the subroutine to create the menu
customer_array "${client[@]}"
