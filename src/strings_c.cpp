unsigned int GetStringLength(char *string)
{
	unsigned int count = 0;
	while (*string != 0)
	{
		string++; count++;
	}
	return count;
}

bool StringEquals(char *StringA, char *StringB)
{
	unsigned int StringALength = GetStringLength(StringA);
	unsigned int StringBLength = GetStringLength(StringB);
	if (StringALength == StringBLength)
	{
		for (unsigned int x = 0; x < StringALength; x++)
		{
			if (*StringA++ == *StringB++)
			{
				continue;
			}
			else
			{
				return false;
			}
		}
	}
	else
	{
		return false;
	}
	return true;
}
