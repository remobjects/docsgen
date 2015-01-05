using System;
using System.Reflection;
using System.Runtime.CompilerServices;

namespace DotLiquid.Util
{
	internal static class TypeUtility
	{
		private const TypeAttributes AnonymousTypeAttributes = TypeAttributes.NotPublic;
		private static System.Collections.Generic.Dictionary<Type,bool> isDefined = new System.Collections.Generic.Dictionary<Type,Boolean>();

		public static bool IsAnonymousType(Type t)
		{
			bool res;
			if (isDefined.TryGetValue(t, out res)) return res;
			res = Attribute.IsDefined(t, typeof(CompilerGeneratedAttribute), false)
				&& t.IsGenericType
					&& (t.Name.Contains("AnonymousType") || t.Name.Contains("AnonType"))
						&& (t.Name.StartsWith("<>") || t.Name.StartsWith("VB$"))
							&& (t.Attributes & AnonymousTypeAttributes) == AnonymousTypeAttributes;
			isDefined.Add(t, res);
		}
	}
}