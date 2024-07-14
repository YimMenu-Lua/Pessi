--all credits to me and phobos (Very Based) thanks for making the code more optimized and make it looks better :)
gui.show_message("Pessi", "Ghost Of Miami Is Coming...")

log.warning("Use At Your Own Risk This Hasn't Been Tested With YimMenu, But It's Safe With Some Menus..")

local TransactionManager <const> = {};
TransactionManager.__index = TransactionManager

function TransactionManager.new()
    local instance = setmetatable({}, TransactionManager);

    instance.Transactions = {
        {label = "15M (Bend Job Limited)", hash = 0x176D9D54},
        {label = "15M (Bend Bonus Limited)", hash = 0xA174F633},
        {label = "7M (Gang Money Limited)", hash = 0xED97AFC1},
        {label = "3.6M (Casino Heist Money Limited)", hash = 0xB703ED29},
        {label = "2.5M (Gang Money Limited)", hash = 0x46521174},
        {label = "2.5M (Island Heist Money Limited)", hash = 0xDBF39508},
        {label = "2M (Heist Awards Money Limited)", hash = 0x8107BB89},
        {label = "2M (Tuner Robbery Money Limited)", hash = 0x921FCF3C},
        {label = "2M (Business Hub Money Limited)", hash = 0x4B6A869C},
        {label = "1M (Avenger Operations Money Limited)", hash = 0xE9BBC247},
        {label = "1M (Daily Objective Event Money Limited)", hash = 0x314FB8B0},
        {label = "1M (Daily Objective Money Limited)", hash = 0xBFCBE6B6},
        {label = "680K (Betting Money Limited)", hash = 0xACA75AAE},
        {label = "500K (Juggalo Story Money Limited)", hash = 0x05F2B7EE},
        {label = "310K (Vehicle Export Money Limited)", hash = 0xEE884170},
        {label = "200K (DoomsDay Finale Bonus Money Limited)", hash = 0xBA16F44B},
        {label = "200K (Action Figures Money Limited)",  hash = 0x9145F938},
        {label = "200K (Collectibles Money Limited)",    hash = 0xCDCF2380},
        {label = "190K (Vehicle Sales Money Limited)",   hash = 0xFD389995}
    }

    return instance;
end

---@return Table TransactionList
function TransactionManager:GetTransactionList()
    return self.Transactions;
end

---@return Int32 character
function TransactionManager:GetCharacter()
    local _, char = STATS.STAT_GET_INT(joaat("MPPLY_LAST_MP_CHAR"), 0, 1)
    return tonumber(char);
end

---@param Int32 hash 
---@param Int32 category
---@return Int32 price
function TransactionManager:GetPrice(hash)
    return tonumber(NETSHOPPING.NET_GAMESERVER_GET_PRICE(hash, 0x57DE404E, true))
end

 
---@param Int32 hash 
---@param? Int32 amount 
function TransactionManager:TriggerTransaction(item_hash)
	script.execute_as_script("shop_controller", function()
		if NETSHOPPING.NET_GAMESERVER_BASKET_IS_ACTIVE() then
			NETSHOPPING.NET_GAMESERVER_BASKET_END()
		end

		local status, tranny_id = NETSHOPPING.NET_GAMESERVER_BEGIN_SERVICE(-1, 0x57DE404E, item_hash, 0x562592BB, self:GetPrice(item_hash), 2)
		if status then
			NETSHOPPING.NET_GAMESERVER_CHECKOUT_START(tranny_id)
		end
	end)
end

function TransactionManager:Init()
    local tab               = gui.get_tab("Monkey")
    local sub_atm           = tab:add_tab("ATM")
    local sub_transaction   = tab:add_tab("Looped Transactions")
    local checkboxwb        = sub_atm:add_checkbox("Transfer Wallet Money To Bank")
    local checkbox1m        = sub_transaction:add_checkbox("180k Loop")
    local sameline          = sub_transaction:add_sameline()
    local checkbox50k       = sub_transaction:add_checkbox("50K Loop")
    local checkbox100k       = sub_transaction:add_checkbox("100K Loop")
    sub_transaction:add_sameline()
    local bountyloop       = sub_transaction:add_checkbox("Bounty Loop")
    local sub_transactionL  = tab:add_tab("Limited Transactions")

    script.register_looped("1mtransaction", function()
        if checkbox1m:is_enabled() then
            self:TriggerTransaction(0x615762F1)
        end
    end)
    


    script.register_looped("50ktransaction", function(script)
        if(checkbox50k:is_enabled()) then
            self:TriggerTransaction(0x610F9AB4)
        end
    end)

    script.register_looped("100ktransaction", function(script)
        if(checkbox100k:is_enabled()) then 
            self:TriggerTransaction(0x68341DC5);
        end
    end)

    script.register_looped("bountyloop", function(script)
        if(bountyloop:is_enabled()) then 
            self:TriggerTransaction(0xC4F96E65);
            script:sleep(1000);
            self:TriggerTransaction(0x610F9AB4);
        end
    end)
    
    
    script.register_looped("walletbank", function(script)
        if(checkboxwb:is_enabled()) then
            NETSHOPPING.NET_GAMESERVER_TRANSFER_WALLET_TO_BANK(self:GetCharacter(), MONEY.NETWORK_GET_VC_WALLET_BALANCE(self:GetCharacter()))
        end
    end)
    
    for _, stealth in ipairs(self:GetTransactionList()) do
        sub_transactionL:add_button(stealth.label, function()
            self:TriggerTransaction(stealth.hash)
        end)
    end    
end


TransactionManager.new():Init()