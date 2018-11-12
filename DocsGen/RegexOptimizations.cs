using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DotLiquid
{
	public class MyRegex
	{
		static Dictionary<string, System.Text.RegularExpressions.Regex> m = new Dictionary<String,System.Text.RegularExpressions.Regex>();
		public static System.Text.RegularExpressions.Regex GetCachedRegex(string pattern) {
			System.Text.RegularExpressions.Regex x;
			lock(m) {
				if (!m.TryGetValue(pattern, out x)) {
					x = new System.Text.RegularExpressions.Regex(pattern, System.Text.RegularExpressions.RegexOptions.Compiled);
					m[pattern] = x;
				}
			}
			return x;
		}
	public static System.Text.RegularExpressions.MatchCollection Matches(string inp, string pat){
		return GetCachedRegex(pat).Matches(inp);
	}
		public static string Replace(string input, string pattern, string replacement) {
			 return GetCachedRegex(pattern).Replace(input, replacement);
		}
		public static System.Text.RegularExpressions.Match Match(System.String input, System.String pattern) {
			//return System.Text.RegularExpressions.Regex.Match(input, pattern);
			return GetCachedRegex(pattern).Match(input);
		}
	}
}