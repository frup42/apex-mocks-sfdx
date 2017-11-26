/**
 * Copyright (c) 2017, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors
 *      may be used to endorse or promote products derived from this software without
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
public class AccountsSelector
{
    // Instance variable for dependency injection - see README for more details.
    @TestVisible
    private static AccountsSelector instance = null;

    // newInstance helper for dependency injection - see README for more details.
    public static AccountsSelector newInstance()
    {
        if (instance == null)
        {
            instance = new AccountsSelector();
        }

        return instance;
    }

    // Retrieve all the Accounts that have the specified names
    public Account[] getForNames(Set<String> names)
    {
        // Check the requested names are sensible
        names = sanitize(names);
     
        // If there are no names, just return an empty array.
        // Otherwise run SOQL to retrieve matching Accounts.
        return names.isEmpty() ? new Account[]{} : [SELECT Id, Name FROM Account WHERE Name IN :names];
    }

    // Sanitize the input - we don't want a null Set or null/blank elements in the Set
    private static Set<String> sanitize(Set<String> input)
    {
        if (input == null)
        {
            // Prevent null pointer exception
            input = new Set<String>();
        }
        else
        {
            // Don't bother searching for blank names.
            // It's just as easy to remove them from the set as it is to check if they're present first.
            input.remove('');
            input.remove(null);
        }
        
        // Return the sanitized result
        return input;
    }
}
